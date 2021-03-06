Set-Location "C:\Program Files (x86)\Java\jre7\bin\"
Get-VM | ForEach-Object {
	$vmName = $_.Name
	$curDate = Get-Date -Format yyyyMMdd
	$reportPath = "C:\temp\DBUpdateTool\EFS_" + $vmName + "_" + $curDate + ".html"
	$transPath =  "C:\temp\DBUpdateTool\EFS_" + $vmName + "_" + $curDate + ".log"
	$dbURL = "jdbc:jtds:sqlserver://" + $vmName + ":1433/AFPDM"
	IF (Get-Process sqlservr)
	{
		Invoke-Command {.\java.exe -jar C:\temp\DBUpdateTool\DBUpdate130827Tool.jar $dbURL pdm pdm $reportPath > $transPath 2>&1}
		$logContent = Get-Content $transPath
		IF ($logContent[1] -eq "HTML file successfully created!")
		{
			Remove-Item -Path $transPath -Force
		}
	}
}




$vmName = "vs001"
$curDate = Get-Date -Format yyyyMMdd
$reportPath = "C:\temp\DBUpdateTool\EFS_" + $vmName + "_" + $curDate + ".html"
$transPath =  "C:\temp\DBUpdateTool\EFS_" + $vmName + "_" + $curDate + ".log"
$dbURL = "jdbc:jtds:sqlserver://" + $vmName + ":1433/AFPDMInternal"
IF (Get-Process sqlservr)
{
	Invoke-Command {.\java.exe -jar C:\temp\DBUpdateTool\DBUpdate130827Tool.jar $dbURL pdm pdm $reportPath > $transPath 2>&1}
	$logContent = Get-Content $transPath
	IF ($logContent[1] -eq "HTML file successfully created!")
	{
		Remove-Item -Path $transPath -Force
	}
}