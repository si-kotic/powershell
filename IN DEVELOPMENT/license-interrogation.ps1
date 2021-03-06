Get-ADComputer -SearchBase 'OU=APS,DC=aps-cambridge,DC=local' -Filter * | ForEach-Object {
	$report = "" | Select-Object PC,License,Installed,LastChecked
	$pc = $_.DNSHostName
	$report.PC = $_.Name
	$licPath = "\\" + $pc + "\c$\ProgramData\EFS Technology\LaserNet v6.7\Default\LaserNet.license"
	$lic = [XML](Get-Content $licPath)
	IF ($lic.LaserNetLicense.Comment)
	{
		$report.License = $lic.LaserNetLicense.Comment
		$report.Installed = (Get-Item $licPath -Force).CreationTime
		$report.LastChecked = Get-Date
	}
	ELSE
	{
		$report.License = "n/a"
	}
	$report
} | Export-Csv C:\temp\lnlicenses.csv