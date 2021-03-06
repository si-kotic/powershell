
$dBServerInstance = "VS001"
$dBDatabase = "CloseSupportSQL"
$dBUserName = "APS-CAMBRIDGE\simonb"
$dBPassword = ""


$csCalls = Invoke-SQLCmd -ServerInstance $dbServerInstance -Database $dbDatabase -Username $dbUserName -Password $dbPassword -Query "SELECT CALLID FROM CS_CALL WHERE CLOSED IS NULL AND (LEVEL2ID = 3471 OR LEVEL2ID = 80) ORDER BY OPENED DESC"
$csCalls | ForEach-Object {
	$toFPDate = Invoke-SQLCmd -ServerInstance $dbServerInstance -Database $dbDatabase -Username $dbUserName -Password $dbPassword -Query "SELECT TOP 1 hstDateTime FROM CS_HISTORY WHERE HSTRECORDID=25673 AND hstDescription LIKE 'Passed to Formpipe%' ORDER BY hstDateTime DESC"
	$fpRespondDate = Invoke-SQLCmd -ServerInstance $dbServerInstance -Database $dbDatabase -Username $dbUserName -Password $dbPassword -Query "SELECT TOP 1 hstDateTime FROM CS_HISTORY WHERE HSTUSERID=0 AND HSTDATETIME > (SELECT TOP 1 hstDateTime FROM CS_HISTORY WHERE HSTRECORDID=25673 AND hstDescription LIKE 'Passed to Formpipe%' ORDER BY hstDateTime DESC) AND hstNotes LIKE '%Form%Pipe%' ORDER BY hstDateTime ASC"
	$responseTime = $fpRespondDate - $toFPDate
	Write-Output "It took Formpipe $responseTime to respond to CS Call $_"
}


