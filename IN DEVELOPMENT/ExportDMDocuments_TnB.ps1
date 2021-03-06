Param (
#$skey1 = "",
$docDef = "Supplier Invoice or Credit Note",
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
#Write-Verbose -Message "SKEY1 = $skey1"
$docTypeID = (Invoke-Sqlcmd -ServerInstance $dmServerInstance -Database $dmDatabase -Username $dmUserName -Password $dmPassword -Query "SELECT docTypeID FROM tblDocTypes WHERE docTypeName='$docDef'").docTypeID
Write-Verbose -Message "DOCTYPE = $docDef"
Write-Verbose -Message "DOCTYPEID = $docTypeID"
Write-Verbose -Message "RETRIEVING SQL RECORDS..."
$docsToExport = Invoke-Sqlcmd -ServerInstance $dmServerInstance -Database $dmDatabase -Username $dmUserName -Password $dmPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID='$docTypeID'"
$recordCount = $docsToExport.Count
Write-Verbose -Message "$recordCount RECORD(S) FOUND IN DATABASE"
$keyData = "Invoice Number,Order Number,Customer Number,Customer Name,Customer Reference,Invoice Date`n"
IF ($docsToExport.Count -eq 1)
{	
	$curDoc = $docsToExport
	$year = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[0]
	$month = $curDoc.fileArchived.toString().split("/")[1]
	$day = $curDoc.fileArchived.toString().split("/")[0]
	$hour = $curDoc.fileArchived.toString().split("/")[-1].split(" ")[-1].split(":")[0]
	$docID = $curDoc.docID.toString()
	$filename = $docID + "_" + $_.fileVersion.toString() + "." + $_.fileType
	$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $filename
	$keyData += $curDoc.sKey1 + "," + $curDoc.sKey2 + "," + $curDoc.sKey3 + "," + $curDoc.sKey4 + "," + $curDoc.sKey5 + "," + $curDoc.dKey1 + "," + $filePath + "`n"
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
		$docID = $curDoc.docID.toString()
		$filename = $docID + "_" + $_.fileVersion.toString() + "." + $_.fileType
		$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $filename
		$keyData += $curDoc.sKey1 + "," + $curDoc.sKey2 + "," + $curDoc.sKey3 + "," + $curDoc.sKey4 + "," + $curDoc.sKey5 + "," + $curDoc.dKey1 + "," + $filePath + "`n"
		Write-Verbose -Message "MOVING DOCUMENT WHERE DOCID=$docID FROM $filePath TO $destination"
		Copy-Item -Path $filePath -Destination $destination # Should be replaced with the line below when testing is complete.
		#Move-Item -Path $filePath -Destination $destination -WhatIf
	}
}
Write-Verbose -Message "WRITING KEY DATA TO CSV FILE $csvFile..."
$csvFilePath = $destination + "\keyData.csv"
$keyData | Out-File $csvFilePath
$csv = Get-Content $csvFilePath
$csv[1..$csv.Count] | Set-Content $csvFilePath
Write-Verbose -Message "KEY DATA WRITTEN TO CSV FILE $csvFile..."
#Write-Verbose -Message "REMOVING $recordCount RECORD(S) FROM SQL SERVER..."
#Invoke-Sqlcmd  -ServerInstance $dbServerInstance -Database $dbDatabase -Username $dbUserName -Password $dbPassword -Query "DELETE FROM table"