$ServerInstance = "TECH018\SQLEXPRESS"
$Database = "PrinterMonitoring"
$UserName = "pdm"
$Password = "pdm"

$printers = Get-WmiObject -Class Win32_Printer
$printJobs = Get-WmiObject -Class Win32_PrintJob

$printers.Name | ForEach-Object {
	#$report = "" | Select "Printer Name",JobID,Document,"Pages Printed","Time Submitted","Elapsed Time",Owner,"Paper Length","Paper Size","Paper Width","Print Processor",Priority,Size
	$curPrinter = $_
	$report."Printer Name" = $curPrinter
	$printJobs | Where-Object {$_.Name.Split(",")[0] -eq $curPrinter} | ForEach-Object {
		$jobID = $_.JobID
		$document = $_.Document
		$pagesPrinted = $_.PagesPrinted
		$timeSubmitted = [Management.ManagementDateTimeConverter]::ToDateTime($_.TimeSubmitted)
		$elapsedTime = [Management.ManagementDateTimeConverter]::ToDateTime($_.ElapsedTime)
		$owner = $_.Owner
		$paperLength = $_.PaperLength
		$paperSize = $_.PaperSize
		$paperWidth = $_.PaperWidth
		$printProcessor = $_.PrintProcessor
		$priority = $_.Priority
		$size = $_.Size
	
<#		$report.JobID = $_.JobID
		$report.Document = $_.Document
		$report."Pages Printed" = $_.PagesPrinted
		$timeSubmitted = [Management.ManagementDateTimeConverter]::ToDateTime($_.TimeSubmitted)
		$report."Time Submitted" = $timeSubmitted
		$report."Elapsed Time" = [Management.ManagementDateTimeConverter]::ToDateTime($_.ElapsedTime)
		$report.Owner = $_.Owner
		$report."Paper Length" = $_.PaperLength
		$report."Paper Size" = $_.PaperSize
		$report."Paper Width" = $_.PaperWidth
		$report."Print Processor" = $_.PrintProcessor
		$report.Priority = $_.Priority
		$report.Size = $_.Size
		$report#>
		

		$jobInSQL = (Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "SELECT * FROM PrintJobs WHERE PrinterName='$curPrinter' AND JobID=$jobID AND TimeSubmitted='$TimeSubmitted'")
		IF ($jobInSQL)
		{
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "UPDATE PrintJobs SET Document='$document',PagesPrinted='$pagesPrinted',ElapsedTime='$elapsedTime',Owner='$owner',PaperLength=$paperLength,PaperSize='$paperSize',PaperWidth=$paperWidth,PrintProcessor='$printProcessor',Priority=$priority,Size=$size WHERE PrinterName='$curPrinter' AND JobID=$jobID AND TimeSubmitted='$TimeSubmitted'"
		}
		ELSE
		{
			Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "INSERT INTO PrintJobs VALUES ('$curPrinter',$jobID,'$document','$pagesPrinted','$TimeSubmitted','$elapsedTime','$owner',$paperLength,'$paperSize',$paperWidth,'$printProcessor',$priority,$size)"
		}
	}
	[GC]::Collect()
} | Export-Csv -Path C:\temp\PrintJobs.csv