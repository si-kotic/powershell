
# Settings
$root = "P:\LaserNet Testing\6.7.0\FullTesting\Resources\LOAD"
$testID = "0100"
$scenario = "Spool > PCL"
$inputFolder0 = "$root\$testID\File_Input0\"
$inputFolder1 = "$root\$testID\File_Input1\"
$inputFolder2 = "$root\$testID\File_Input2\"
$inputFolder3 = "$root\$testID\File_Input3\"
$inputFolder4 = "$root\$testID\File_Input4\"
$finalDest = "$root\$testID\File_Output\"
$processingSource = "$root\$testID\Processing\"
$source = "$root\$testID\Source\"
$sample = "$root\$testID\Sample\"
$printer = Get-WmiObject -Class Win32_Printer | Where {$_.Name -eq "HP LaserJet 4100 Series PS Class Driver"} #Probably needs changing!
$printerShareName = "\\localhost\" + $printer.ShareName

# Script
$null = $printer.Pause()
$startTime = Get-Date
Print /D:$printerShareName (Get-ChildItem $sample).FullName
While (!(Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $printer.Name}))
	{Start-Sleep -Milliseconds 0.5}
$endTime = Get-Date
$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $printer.Name}
IF (!$printJobs.count)
	{$outCount = 1}
ELSE
	{$outCount = $printJobs.Count}
$inExt = "SPL"
$outExt = "PCL"
$totalDuration = $endTime - $startTime
$totalDurationString = $totalDuration.toString()
# CALCULATE TIME PER JOB!!!!
Write-Output @"
Test ID, Scenario, Start Time, End Time, Input Type, Number of Input Modules, Input Quantity, Document Count, Output Type, Output Quantity, Total Duration
$testID, $scenario, $startTime, $endTime, $inExt, 1, 1, 1, $outExt, $outCount, $totalDurationString
"@ | Out-File -FilePath "$processingSource\test.log"
$printJobs | Foreach {$_.Delete()}
$null = $printer.Resume()



$startTime = Get-Date
$sourceFiles = Get-ChildItem $sample
$sourceFiles | ForEach-Object {
	$inExt = $_.Extension
	For ($i=0;$i<1000;$i++)
		{Copy-Item -Path $_ -Destination ("C:\TempLocation\" + $_.Name + "_" + $i + $inExt) -Force} #Need to change destination
}
LaserNet-LoadTesting -Source C:\TempLocation\ <# <-^ FROM ABOVE #> -Destination0 $dest0 -Destination1 $dest1 -Destination2 $dest2 -Destination3 $dest3 -Destination4 $dest4 -Breakpoint $breakpoint

While ((Get-ChildItem $finalDest).Count -lt 1000)
{
	Sleep -Milliseconds 1
}
$endTime = Get-Date
$outExt = (Get-ChildItem $finalDest)[0].Extension

Write-Output $startTime, $endTime, $sourceFiles.Count, $inExt, $outExt, 
