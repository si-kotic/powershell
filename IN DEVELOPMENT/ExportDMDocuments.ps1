Param (
$skey1 = "",
$destination = "C:\temp\lndest\",
$dBServerInstance = "LOCALHOST\SQLEXPRESS",
$dBDatabase = "AFPDM",
$dBUserName = "pdm",
$dBPassword = "pdm",
$dmServerInstance = "LOCALHOST\SQLEXPRESS",
$dmDatabase = "AFPDM",
$dmUserName = "pdm",
$dmPassword = "pdm"
)

IF (!(Test-Path $destination))
{
	Write-Verbose -Message "DESTINATION PATH NOT FOUND."
	Write-Verbose -Message "CREATING $destination ..."
	New-Item -Path $destination -ItemType Directory -Force
}
$archivePath = (Invoke-Sqlcmd -ServerInstance $dmServerInstance -Database $dmDatabase -Username $dmUserName -Password $dmPassword -Query "SELECT * FROM tblArchiveDirectories")[0].Path
Write-Verbose -Message "ARCHIVE PATH = $archivePath"
Write-Verbose -Message "SKEY1 = $skey1"
Write-Verbose -Message "RETRIEVING SQL RECORDS..."
$docsToExport = Invoke-Sqlcmd -ServerInstance $dmServerInstance -Database $dmDatabase -Username $dmUserName -Password $dmPassword -Query "SELECT * FROM tblDocuments WHERE skey1='$skey1'"
$recordCount = $docsToExport.Count
Write-Verbose -Message "$recordCount RECORD(S) FOUND IN DATABASE"
IF ($docsToExport.Count -eq 1)
{	
	$curDoc = $docsToExport
	$year = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[0]
	$month = $curDoc.fileArchived.toString().split("/")[1]
	$day = $curDoc.fileArchived.toString().split("/")[0]
	$hour = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[-1].split(":")[0]
	$filename = $curDoc.docID.toString() + "_" + $_.fileVersion.toString() + "." + $_.fileType
	$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $filename
	Write-Verbose -Message "MOVING DOCUMENT WHERE DOCID=$docID FROM $filePath TO $destination"
	Copy-Item -Path $filePath -Destination $destination # Should be replaced with the line below when testing is complete.
	#Move-Item -Path $filePath -Destination $destination -WhatIf
}
ELSEIF ($docsToExport.Count -gt 1)
{
	$docsToExport | ForEach-Object {
		$curDoc = $_
		$year = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[0]
		$month = $curDoc.fileArchived.toString().split("/")[1]
		$day = $curDoc.fileArchived.toString().split("/")[0]
		$hour = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[-1].split(":")[0]
		$filename = $curDoc.docID.toString() + "_" + $_.fileVersion.toString() + "." + $_.fileType
		$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $filename
		Write-Verbose -Message "MOVING DOCUMENT WHERE DOCID=$docID FROM $filePath TO $destination"
		Copy-Item -Path $filePath -Destination $destination # Should be replaced with the line below when testing is complete.
		#Move-Item -Path $filePath -Destination $destination -WhatIf
	}
}
Write-Verbose -Message "REMOVING $recordCount RECORD(S) FROM SQL SERVER..."
Invoke-Sqlcmd  -ServerInstance $dbServerInstance -Database $dbDatabase -Username $dbUserName -Password $dbPassword -Query "DELETE FROM table"