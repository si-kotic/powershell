<#

Common Functions for LaserNet v6.7 Load Testing.

#>

## FOLDER/LOCATION CONFIGURATION
Function lnTest-Conf {
	Write-Verbose -Message "CONFIGURE FILEPATHS AND PRINTERS"
	$global:root = "C:\LaserNet Testing\6.7.0\Full Testing\Resources\LOAD"
	$global:inputFolder0 = "$root\CommonComponents\File_Input0\"
	$global:inputFolder1 = "$root\CommonComponents\File_Input1\"
	$global:inputFolder2 = "$root\CommonComponents\File_Input2\"
	$global:inputFolder3 = "$root\CommonComponents\File_Input3\"
	$global:inputFolder4 = "$root\CommonComponents\File_Input4\"
	$global:finalDest = "$root\CommonComponents\File_Output\"
	$global:processingSource = "$root\Results\"
	$global:source = "$root\Build\"
	$global:sample = "$root\$testID\"
	$global:inPrinter = Get-WmiObject -Class Win32_Printer | Where {$_.Name -eq "LaserNetInput"}
	$global:inPrinterShareName = "\\localhost\" + $inPrinter.ShareName
	$global:outPrinter = Get-WmiObject -Class Win32_Printer | Where {$_.Name -eq "LNOutput"}
	$global:outPrinterShareName = "\\localhost\" + $outPrinter.ShareName
}

## CREATING INPUT FILES/JOBS
Function lnTest-CreateJobs {
Param (
$inData,
$numJobs
)
	Write-Verbose -Message "CREATE MULTIPLE INPUT JOBS WITHIN A FILE"
	$global:tempPath = "$root\TempInData"
	$outData = "$root\TempInData\SampleInputData.txt"
	New-Item -Path $tempPath -Name SampleInputData.txt -ItemType File -Force
	$formFeed = Get-Content "$root\CommonComponents\FormFeed.txt"
	$originalData = Get-Content $inData
	Add-Content $outData $originalData
	For ($i = 0; $i -lt ($numJobs-1); $i++) {
		Add-Content $outData $formFeed
		Add-Content $outData $originalData[1..($originalData.Count-1)]
	}
}

Function lnTest-CreateFiles {
Param (
$numJobs
)
	Write-Verbose -Message "CREATE MULTIPLE INPUT FILES"
	$global:tempPath = "$root\TempInData"
	New-Item -Path $root -Name TempInData -ItemType Directory -Force
	For ($i=0;$i -lt $numJobs;$i++)
		{
			Get-Childitem $sample | Foreach-Object {
				Copy-Item -Path $_.FullName -Destination ($tempPath + "\" + $testID + "_" + $i + $_.Extension) -Force
			}
		}
}

## MONITORING OUTPUTS
Function lnTest-MonitorPrinter {
Param (
$numJobs,
$timeout
)
	Write-Verbose -Message "BEGIN MONITORING OUTPUT PRINTER PORT"
	$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}
	$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
	$endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
	While (($printJobs.Count -lt $numJobs) -and ($endTime -gt (Get-Date).AddSeconds(-$timeout)))
		{
			Start-Sleep -Seconds 60
			$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}
			$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
			$endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
		}
	Write-Verbose -Message "MONITORING LOOP COMPLETE.  OUTPUT RESULTS"
	$global:printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $outPrinter.Name}
	IF (!$printJobs.count)
		{
			$global:endTime = $printJobs.ConvertToDateTime($printJobs.TimeSubmitted)
			$global:outCount = 1
		}
	ELSE
		{
			$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
			$global:endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
			$global:outCount = $printJobs.Count
		}
}

Function lnTest-MonitorFolder {
Param (
$numJobs,
$timeout
)
	Write-Verbose -Message "BEGIN MONITORING OUTPUT FOLDER"
	$outputFiles = Get-ChildItem $finalDest
	$lastJob = ($outputFiles | Sort-Object CreationTime -Descending)[0]
	$endTime = $lastJob.CreationTime
	While (($outputFiles.Count -lt $numJobs) -and ($endTime -gt (Get-Date).AddSeconds(-$timeout)))
		{
			Start-Sleep -Seconds 60
			$outputFiles = Get-ChildItem $finalDest
			$lastJob = ($outputFiles | Sort-Object CreationTime -Descending)[0]
			$endTime = $lastJob.CreationTime
		}
	Write-Verbose -Message "MONITORING LOOP COMPLETE.  OUTPUT RESULTS"
	$QuOutputFiles = $outputFiles.Count
	Write-Verbose -Message "LAST JOB TIME = $endTime | OUTPUT FILES = $QuOutputFiles"
	$outputFiles = Get-ChildItem $finalDest
	IF ($outputFiles.Count -eq 1)
		{
			$global:outExt = $outputFiles.Extension.SubString(1)
			$global:endTime = $outputFiles.CreationTime
		}
	ELSE
		{
			$global:outExt = $outputFiles[0].Extension.SubString(1)
			$global:endTime = ($outputFiles | Sort-Object CreationTime -Descending)[0].CreationTime
		}
	$global:outCount = $outputFiles.Count
}

## CREATING/POPULATING/EXPORTING RESULTS TABLE
Function Create-LNTestingTable {
	Write-Verbose -Message "CREATE RESULTS TABLE READY FOR POPULATION"
	$global:table = New-Object system.Data.DataTable “LaserNet Testing”

	$global:col1 = New-Object system.Data.DataColumn TestID,([string])
	$global:col2 = New-Object system.Data.DataColumn StartTime,([string])
	$global:col3 = New-Object system.Data.DataColumn EndTime,([string])
	$global:col4 = New-Object system.Data.DataColumn InputType,([string])
	$global:col5 = New-Object system.Data.DataColumn NumberOfInputModules,([string])
	$global:col6 = New-Object system.Data.DataColumn InputQuantity,([string])
	$global:col7 = New-Object system.Data.DataColumn DocumentCount,([string])
	$global:col8 = New-Object system.Data.DataColumn OutputType,([string])
	$global:col9 = New-Object system.Data.DataColumn OutputQuantity,([string])
	$global:col10 = New-Object system.Data.DataColumn TotalDuration,([string])
	$global:col11 = New-Object system.Data.DataColumn TimePerJob,([string])

	$global:table.columns.add($col1)
	$global:table.columns.add($col2)
	$global:table.columns.add($col3)
	$global:table.columns.add($col4)
	$global:table.columns.add($col5)
	$global:table.columns.add($col6)
	$global:table.columns.add($col7)
	$global:table.columns.add($col8)
	$global:table.columns.add($col9)
	$global:table.columns.add($col10)
	$global:table.columns.add($col11)
}

Function Populate-LNTestingTable {
Param (
$testID,
$startTime,
$endTime,
$inExt,
$inMods,
$inCount,
$docCount,
$outExt,
$outCount,
$totalDurationString,
$timePerJob
)
	Write-Verbose -Message "POPULATE RESULTS TABLE"
	$row = $table.NewRow()
	$row.TestID = $testID
	$row.StartTime = $startTime
	$row.EndTime = $endTime
	$row.InputType = $inExt
	$row.NumberOfInputModules = $inMods
	$row.InputQuantity = $inCount
	$row.DocumentCount = $docCount
	$row.OutputType = $outExt
	$row.OutputQuantity = $outCount
	$row.TotalDuration = $totalDurationString
	$row.TimePerJob = $timePerJob
	$table.rows.add($row)
}

Function Export-LNTestingTable {
	Write-Verbose -Message "EXPORT RESULTS TABLE TO CSV"
	$table | Export-Csv "$processingSource\$testID.csv"
	$csv = Get-Content "$processingSource\$testID.csv"
	$csv[1..$csv.Count] | Set-Content "$processingSource\$testID.csv"
}