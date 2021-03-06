Get-ChildItem -Recurse | Where {$_.Extension -eq ".spdf"} | Foreach {
      Rename-Item -Path $_.FullName -NewName ($_.FullName.TrimEnd($_.Extension) + ".pdf") -Force
      $docID = $_.Name.Split("_")[0]
      $fileVersion = $_.Name.Split("_")[1].TrimEnd($_.Extension)
      Invoke-SQLcmd -ServerInstance "TECH018WIN8\SQLEXPRESS" -Database "AFPDM" -Username pdm -Password pdm -Query "UPDATE tblDocuments SET fileType='PDF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

###################################################################################################################

$sqlInstance = "TECH010"
$sqlDB = "AFPDM"
$sqlUsername = "pdm"
$sqlPassword = "pdm"
$docType = "Invoice"
$docTypeID = (Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT docTypeID FROM tblDocTypes WHERE docTypeName='$docType'").docTypeID
$archivePath = (Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblArchiveDirectories")[0].Path
$records = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID=$docTypeID"
$records | ForEach-Object {
	$docID = $_.docID
	$version = $_.fileVersion
	$baseName = $docID + "_" + $version
	$year = $_.FileArchived.Year
	$month = $_.FileArchived.Month
	$day = $_.FileArchived.Day
	$hour = $_.FileArchived.Hour
	$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\"
	Get-ChildItem -Path $filePath | Where {$_.BaseName -eq $baseName} | ForEach-Object {
		IF ($_.Extension -eq "TIF")
		{
			Write-Output "Changing fileType from PDF to TIF for docID=$docID and fileVersion=$fileVersion in tblDocuments"
			Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocuments SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
		}
	}
$records = {Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID=$docTypeID"; Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocumentHistory WHERE docTypeID=$docTypeID"}
$records | ForEach-Object {
	$docID = $_.docID
	$version = $_.fileVersion
	$baseName = $docID + "_" + $version
	$year = $_.FileArchived.Year
	$month = $_.FileArchived.Month
	$day = $_.FileArchived.Day
	$hour = $_.FileArchived.Hour
	$filePath = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\"
	Get-ChildItem -Path $filePath | Where {$_.BaseName -eq $baseName} | ForEach-Object {
		IF ($_.Extension -eq "TIF")
		{
			Write-Output "Changing fileType from PDF to TIF for docID=$docID and fileVersion=$fileVersion in tblDocumentHistory"
			Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocumentHistory SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
		}
	}
}

###################################################################################################################

$sqlInstance = "TECH010"
$sqlDB = "AFPDM"
$sqlUsername = "pdm"
$sqlPassword = "pdm"
$docType = "Invoice"
$docTypeID = (Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT docTypeID FROM tblDocTypes WHERE docTypeName='$docType'").docTypeID
$archivePath = (Invoke-Sqlcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblArchiveDirectories")[0].Path
#$archivePath = "\\TECH010\C$\ARCHIVE_TEST\"
Get-ChildItem -Path $archivePath -Recurse | Where {$_.Extension -eq ".TIF"} | Foreach {
    $docID = $_.Name.Split("_")[0]
    $fileVersion = $_.Name.Split("_")[1].TrimEnd($_.Extension)
    Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocuments SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
    Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocumentHistory SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

$records = Get-ChildItem -Path $archivePath -Recurse | Where {$_.Extension -eq ".TIF"} | Foreach {
    $docID = $_.Name.Split("_")[0]
    $fileVersion = $_.Name.Split("_")[1].TrimEnd($_.Extension)
    $doc = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docID=$docID AND fileVersion=$fileVersion"
    $docHist = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocumentHistory WHERE docID=$docID AND fileVersion=$fileVersion"
}

###################################################################################################################

$sqlInstance = "TECH010"
$sqlDB = "AFPDM"
$sqlUsername = "pdm"
$sqlPassword = "pdm"
$docType = "Invoice"

$docRecs = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID=$docTypeID"
$docRecs | Foreach {
	$docID = $_.docID
	$fileVersion = $_.fileVersion
	$year = $_.fileArchived.toString().Split("/")[-1].Split(" ")[0]
	$month = $_.fileArchived.toString().Split("/")[1]
	$day = $_.fileArchived.toString().Split("/")[0]
	$hour = $_.fileArchived.toString().Split("/")[-1].Split(" ")[-2].Split(":")[0]
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$newName = $docID.toString() + "_" + $fileVersion.toString() + ".TIF"
	Rename-Item -Path $fileName -NewName $newName -Force
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocuments SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocumentHistory WHERE docTypeID=$docTypeID" | Foreach {
	$docID = $_.docID
	$fileVersion = $_.fileVersion
	$year = "{0:D2}" -f $_.fileArchived.Year.toString()
	$month = "{0:D2}" -f $_.fileArchived.Month.toString()
	$day = "{0:D2}" -f $_.fileArchived.Day.toString()
	$hour = "{0:D2}" -f $_.fileArchived.Hour.toString()
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$newName = $docID.toString() + "_" + $fileVersion.toString() + ".TIF"
	Rename-Item -Path $fileName -NewName $newName -Force
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocumentHistory SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

###################################################################################################################

$sqlInstance = "EFSLN-UAT"
$sqlDB = "AFPDM"
$sqlUsername = "pdm"
$sqlPassword = "pdm"
$docType = "Cheque"
$docTypeID = 25769803796
$archivePath = "C:\ARCHIVE"


$records = $files | Foreach {
	$docID = $_.Name.Split("_")[0]
	$fileVersion = $_.Name.Split("_")[1].TrimEnd($_.Extension)
	$doc = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docID=$docID AND fileVersion=$fileVersion"
	$docHist = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocumentHistory WHERE docID=$docID AND fileVersion=$fileVersion"
	IF (!($doc -or $docHist))
	{$_.FullName | Out-File C:\temp\missingDocs.txt -Append}
	$doc
	$docHist
}


$files | Foreach {
	$docID = $_.Name.Split("_")[0]
	$fileVersion = $_.Name.Split("_")[1].TrimEnd($_.Extension)
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocuments SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocumentHistory SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

# I THINK THIS IS THE ONE I RAN AT BANCO UNICO #
$docRecs = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID=$docTypeID AND WHERE fileType='PDF'"
$docRecs | Foreach {
	$docID = $_.docID
	$fileVersion = $_.fileVersion
	$year = $_.fileArchived.toString().Split("/")[-1].Split(" ")[0]
	$month = $_.fileArchived.toString().Split("/")[1]
	$day = $_.fileArchived.toString().Split("/")[0]
	$hour = $_.fileArchived.toString().Split("/")[-1].Split(" ")[-2].Split(":")[0]
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$newName = $docID.toString() + "_" + $fileVersion.toString() + ".TIF"
	Rename-Item -Path $fileName -NewName $newName -Force
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocuments SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

# AND THIS ONE FOR DOCUMENT HISTORY #
Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocumentHistory WHERE docTypeID=$docTypeID AND WHERE fileType='PDF'" | Foreach {
	$docID = $_.docID
	$fileVersion = $_.fileVersion
	$year = "{0:D2}" -f $_.fileArchived.Year.toString()
	$month = "{0:D2}" -f $_.fileArchived.Month.toString()
	$day = "{0:D2}" -f $_.fileArchived.Day.toString()
	$hour = "{0:D2}" -f $_.fileArchived.Hour.toString()
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$newName = $docID.toString() + "_" + $fileVersion.toString() + ".TIF"
	Rename-Item -Path $fileName -NewName $newName -Force
	Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "UPDATE tblDocumentHistory SET fileType='TIF' WHERE docID=$docID AND fileVersion=$fileVersion"
}

$rec = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT * FROM tblDocuments WHERE docTypeID=283467935754"

$records = Invoke-SQLcmd -ServerInstance $sqlInstance -Database $sqlDB -Username $sqlUsername -Password $sqlPassword -Query "SELECT TOP 1 * FROM tblDocuments"

$records | Foreach {
	$docID = $_.docID
	$fileVersion = $_.fileVersion
	$year = $_.fileArchived.toString().Split("/")[-1].Split(" ")[0]
	$month = $_.fileArchived.toString().Split("/")[1]
	$day = $_.fileArchived.toString().Split("/")[0]
	$hour = $_.fileArchived.toString().Split("/")[-1].Split(" ")[-2].Split(":")[0]
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$fileName
}

$date | Foreach {
	$year = $date.toString().Split("/")[-1].Split(" ")[0]
	$month = $date.toString().Split("/")[1]
	$day = $date.toString().Split("/")[0]
	$hour = $date.toString().Split("/")[-1].Split(" ")[-2].Split(":")[0]
	$fileName = $archivePath + "\" + $year + "\" + $month + "\" + $day + "\" + $hour + "\" + $docID.toString() + "_" + $fileVersion.toString() + "." + $_.fileType
	$fileName
}





