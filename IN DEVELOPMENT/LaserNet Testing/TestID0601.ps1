<#
Test 0601
#>
#[CmdletBinding(SupportsShouldProcess=$true)]

$global:testID = "0601"
$numJobs = 1
$count = 0
Write-Verbose -Message "LOAD COMMON FUNCTIONS FOR TESTING"
. ((Split-Path $MyInvocation.MyCommand.Path) + "\LNTestingCommonFunctions.ps1")
Write-Verbose -Message "RUN FUNCTION FOR CONFIGURING LOCATIONS/PRINTERS ETC (SETTINGS)"
lnTest-Conf
Create-LNTestingTable

# Script
$startTime = Get-Date
Copy-Item -Path (Get-ChildItem $sample).FullName -Destination $inputFolder0 -Force
Start-Sleep -Seconds 60
While (!(Get-ChildItem $finalDest) -and ($count -lt 2))
	{
		$count++
		Start-Sleep -Seconds 60
	}
$outputFiles = Get-ChildItem $finalDest
IF ($outputFiles.count -eq 1)
	{
		$outExt = $outputFiles.Extension.SubString(1)
		$endTime = $outputFiles.CreationTime
	}
ELSE
	{
		$outExt = $outputFiles[0].Extension.SubString(1)
		$endTime = ($outputFiles | Sort-Object CreationTime -Descending)[0].CreationTime
	}
$outCount = $outputFiles.Count
$inExt = "TXT"
$totalDuration = ($endTime - $startTime).TotalMilliseconds
$totalDurationString = $totalDuration.toString() + "ms"
$timePerJob = $totalDuration / $numJobs # CALCULATE TIME PER JOB!!!!
$inMods = '1'
$inCount = '1'
$docCount = '1'
Populate-LNTestingTable $testID $startTime $endTime $inExt $inMods $inCount $docCount $outExt $outCount $totalDurationString $timePerJob
Export-LNTestingTable
Get-ChildItem $finalDest | ForEach-Object {Remove-Item -Path $_.FullName -Force -Confirm:$false}