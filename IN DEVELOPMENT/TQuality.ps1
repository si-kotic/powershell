$Report = "" | Select-Object -Property DayOfWeek,Date,Time,Diff,EventsSinceLastCrash
$winEvents = Get-WinEvent -LogName System | Where {$_.Id -eq 4006}
$Crashes | Foreach-Object {
	$Report.Diff = $_.CreationTimeUTC.Date - $OldDate
	$OldDate = $_.CreationTimeUTC.Date
	$Report.DayOfWeek = $_.CreationTimeUTC.DayOfWeek
	$Date = $_.CreationTimeUTC
	$Report.Date = $Date.ToShortDateString()
	$Report.Time = $Date.ToShortTimeString()
	$Report.EventsSinceLastCrash = ($winEvents | Where {($_.TimeCreated -gt $OldDate) -and ($_.TimeCreated -le $Date)}).Count
	$Report
} | FT


$Report = "" | Select-Object -Property Name,Handles,"Memory(M)","CPU(s)",ID
Get-Process lnService | ForEach-Object {
	$Report.Name = $_.ProcessName
	$Report.Handles = $_.Handles
	$Report."Memory(M)" = $_.WS/1mb
	$Report."CPU(s)" = $_.CPU
	$Report.ID = $_.Id
	$Report
} | FT

$printers = Get-WmiObject -Class Win32_Printer | Where {($_.Name -like "EFS*") -or ($_.Name -like "EAS*")}
While ((Get-Service "LaserNet v6.6*").Status -eq "Running") {
	Get-ChildItem | Where {($_.Name -like "Bourne Leisure*.grab") -or ($_.Name -like "Invoice Despatch*.grab")} | Foreach {
		Copy-Item $_.FullName -Destination \\localhost\intest -Force
	}
	Start-Sleep -Seconds 300
	$printers | Foreach {
		$p = $_.Name
		Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $p} | Foreach {
			$_.Delete()
		}
	}
}