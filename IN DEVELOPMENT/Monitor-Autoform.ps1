##  CONFIG  ##
$dmService = "AUTOFORM DM Server 7.2.0"
$lnService = "LaserNet v6.7 (Default:3279)"
$jfService = "JFinder V2 Server"
$imqService = "iMQ_Broker"
$sqlService = "SQL Server (SQLEXPRESS)"

$ver = $dmService.Substring(19,5)
$dmLocation = ((Get-WmiObject -Class Win32_Service | Where-Object {$_.Name -eq $dmService.Name}).PathName -Split "-s")[0].Substring(1)
$dmLocation = $dmLocation.Substring(0,$dmLocation.length-18) + "\standalone\configuration\"


##  MONITORING ##
$dmServiceStatus = (Get-Service -DisplayName $dmService).Status
$lnServiceStatus = (Get-Service -DisplayName $lnService).Status
$jfServiceStatus = (Get-Service -DisplayName $jfService).Status
$imqServiceStatus = (Get-Service -DisplayName $imqService).Status
$sqlServiceStatus = (Get-Service -DisplayName $sqlService).Status


##  OUTPUT ##
Write-Output ("AUTOFORM|DM Service Status...		" + $dmServiceStatus)
Write-Output ("LaserNet Service Status...		" + $lnServiceStatus)
Write-Output ("JFinder Service Status...		" + $jfServiceStatus)
Write-Output ("iMQ Broker Service Status...		" + $imqServiceStatus)
Write-Output ("SQL Server Service Status...		" + $sqlServiceStatus)