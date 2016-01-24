<#
Test 0405
#>
#[CmdletBinding(SupportsShouldProcess=$true)]

$global:testID = "0405"
$numJobs = 500000
$timeout = 60
Write-Verbose -Message "LOAD COMMON FUNCTIONS FOR TESTING"
. ((Split-Path $MyInvocation.MyCommand.Path) + "\LNTestingCommonFunctions.ps1")
Write-Verbose -Message "RUN FUNCTION FOR CONFIGURING LOCATIONS/PRINTERS ETC (SETTINGS)"
lnTest-Conf
Create-LNTestingTable

# Script
lnTest-CreateFiles -numJobs $numJobs
$startTime = Get-Date
Get-ChildItem $tempPath | Foreach-Object {Copy-Item -Path $_.FullName -Destination $inputFolder0 -Force}
Start-Sleep -Seconds 60
lnTest-MonitorFolder $numJobs $timeout
$outCount = $outputFiles.Count
$inExt = "XML"
$totalDuration = ($endTime - $startTime).TotalSeconds
$totalDurationString = $totalDuration.toString()
$timePerJob = $totalDuration / $numJobs # CALCULATE TIME PER JOB!!!!
$inMods = '1'
$inCount = '1'
$docCount = $numJobs
Populate-LNTestingTable $testID $startTime $endTime $inExt $inMods $inCount $docCount $outExt $outCount $totalDurationString $timePerJob
Export-LNTestingTable
Remove-Item $tempPath -Recurse -Confirm:$false
Get-ChildItem $finalDest | ForEach-Object {Remove-Item -Path $_.FullName -Force -Confirm:$false}