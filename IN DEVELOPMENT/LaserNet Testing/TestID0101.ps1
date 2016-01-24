<#
Test 0101
#>
#[CmdletBinding(SupportsShouldProcess=$true)]

$global:testID = "0101"
$numJobs = 1
$count = 0
Write-Verbose -Message "LOAD COMMON FUNCTIONS FOR TESTING"
. ((Split-Path $MyInvocation.MyCommand.Path) + "\LNTestingCommonFunctions.ps1")
Write-Verbose -Message "RUN FUNCTION FOR CONFIGURING LOCATIONS/PRINTERS ETC (SETTINGS)"
lnTest-Conf
Create-LNTestingTable

# Script
$null = $outPrinter.Pause()
$startTime = Get-Date
Print /D:$inPrinterShareName (Get-ChildItem $sample).FullName
While (!(Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}) -and ($count -lt 2))
	{
		$count++
		Start-Sleep -Seconds 60
	}
$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}
$endTime = $printJobs.ConvertToDateTime($printJobs.TimeSubmitted)
IF (!$printJobs.count)
	{$outCount = 1}
ELSE
	{$outCount = $printJobs.Count}
$inExt = "SPL"
$outExt = "PCL"
$totalDuration = ($endTime - $startTime).TotalSeconds
$totalDurationString = $totalDuration.toString()
$timePerJob = $totalDuration / $numJobs # CALCULATE TIME PER JOB!!!!
$inMods = '1'
$inCount = '1'
$docCount = '1'
Populate-LNTestingTable $testID $startTime $endTime $inExt $inMods $inCount $docCount $outExt $outCount $totalDurationString $timePerJob
Export-LNTestingTable
$printJobs | Foreach {$_.Delete()}
$null = $outPrinter.Resume()
