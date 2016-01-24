<#
Test 0203
#>
#[CmdletBinding(SupportsShouldProcess=$true)]

$global:testID = "0203"
$numJobs = 1000
$timeout = 60
Write-Verbose -Message "LOAD COMMON FUNCTIONS FOR TESTING"
. ((Split-Path $MyInvocation.MyCommand.Path) + "\LNTestingCommonFunctions.ps1")
Write-Verbose -Message "RUN FUNCTION FOR CONFIGURING LOCATIONS/PRINTERS ETC (SETTINGS)"
lnTest-Conf
Create-LNTestingTable

# Script
lnTest-CreateFiles -numJobs $numJobs
$startTime = Get-Date
Get-ChildItem $tempPath | Foreach-Object {Print /D:$inPrinterShareName $_.FullName}
Start-Sleep -Seconds 60
lnTest-MonitorFolder $numJobs $timeout
#While (!(Get-ChildItem $finalDest) -and ($count -lt 6))
#	{
#		$count++
#		Start-Sleep -Seconds 10
#	}
#$outputFiles = Get-ChildItem $finalDest
#IF ($outputFiles.count -eq 1)
#	{
#		$outExt = $outputFiles.Extension.SubString(1)
#		$endTime = $outputFiles.CreationTime
#	}
#ELSE
#	{
#		$outExt = $outputFiles[0].Extension.SubString(1)
#		$endTime = ($outputFiles | Sort-Object CreationTime -Descending)[0].CreationTime
#	}
$outCount = $outputFiles.Count
$inExt = "SPL"
$totalDuration = ($endTime - $startTime).TotalSeconds
$totalDurationString = $totalDuration.toString()
$timePerJob = $totalDuration / $numJobs # CALCULATE TIME PER JOB!!!!
$inMods = '1'
$inCount = '1'
$docCount = '1'
Populate-LNTestingTable $testID $startTime $endTime $inExt $inMods $inCount $docCount $outExt $outCount $totalDurationString $timePerJob
Export-LNTestingTable
Remove-Item $tempPath -Recurse -Confirm:$false
Get-ChildItem $finalDest | ForEach-Object {Remove-Item -Path $_.FullName -Force -Confirm:$false}