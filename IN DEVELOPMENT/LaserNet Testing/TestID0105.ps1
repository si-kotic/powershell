<#
Test 0105
#>
#[CmdletBinding(SupportsShouldProcess=$true)]

$global:testID = "0105"
$numJobs = 500000
$timeout = 60
Write-Verbose -Message "LOAD COMMON FUNCTIONS FOR TESTING"
. ((Split-Path $MyInvocation.MyCommand.Path) + "\LNTestingCommonFunctions.ps1")
Write-Verbose -Message "RUN FUNCTION FOR CONFIGURING LOCATIONS/PRINTERS ETC (SETTINGS)"
lnTest-Conf
Create-LNTestingTable

# Script
#lnTest-CreateJobs -inData (Get-ChildItem $sample).FullName -numJobs $numJobs
lnTest-CreateFiles -numJobs $numJobs
$null = $outPrinter.Pause()
$startTime = Get-Date
Get-ChildItem $tempPath | Foreach-Object {Print /D:$inPrinterShareName $_.FullName}
Start-Sleep -Seconds 60
lnTest-MonitorPrinter $numJobs $timeout
#While (((Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}).Count -lt $numJobs) -and ($count -lt 60))
#	{
#		$count++
#		Start-Sleep -Seconds 10
#	}
#$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}
#IF (!$printJobs.count)
#	{
#		$endTime = $printJobs.ConvertToDateTime($printJobs.TimeSubmitted)
#		$outCount = 1
#	}
#ELSE
#	{
#		$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
#		$endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
#		$outCount = $printJobs.Count
#	}
$inExt = "SPL"
$outExt = "PCL"
$totalDuration = ($endTime - $startTime).TotalSeconds
$totalDurationString = $totalDuration.toString()
$timePerJob = $totalDuration / $numJobs # CALCULATE TIME PER JOB!!!!
$inMods = '1'
$inCount = '1'
$docCount = $numJobs
Populate-LNTestingTable $testID $startTime $endTime $inExt $inMods $inCount $docCount $outExt $outCount $totalDurationString $timePerJob
Export-LNTestingTable
$printJobs | Foreach {$_.Delete()}
$null = $outPrinter.Resume()
Remove-Item $tempPath -Recurse -Confirm:$false