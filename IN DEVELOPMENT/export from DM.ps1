$ServerInstance = "localhost\sqlexpress"
$Database = "AFPDM"
$UserName = "pdm"
$Password = "pdm"
Get-ChildItem | ForEach-Object {
	$fileName = $_.Name
	$docID = $fileName.TrimEnd($_.Extension).Split("_")[0]
	$fileVer = $fileName.TrimEnd($_.Extension).Split("_")[1]
	
	$docTypeID = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "SELECT docTypeID FROM tblDocuments WHERE docID=$docID"
	
	#MUST CHANGE TO DKEY1!!!
	$dKey1 = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "SELECT dKey1 FROM tblDocuments WHERE docID=$docID"
	$nKey2 = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "SELECT nKey1 FROM tblDocuments WHERE docID=$docID"
	$sKey1 = Invoke-SqlCmd -ServerInstance $ServerInstance -Database $Database -Username $UserName -Password $Password -Query "SELECT sKey1 FROM tblDocuments WHERE docID=$docID"
	IF ($nKey2.nKey2 -eq 1)
		{$company = "Fristads"}
	ELSE
		{$company = "Hejco"}
	
	$date = $dKey1.dKey13.ToString().Split(" ")[0] #MUST CHANGE TO DKEY1!!!
	$year = $date.Split("/")[2]
	$month = $date.Split("/")[1]
	$day = $date.Split("/")[0]
	
	$newName = "E:\PDMExport\" + $company + "\" + $year + "\" + $month + "\" + $year + "_" + $month + "_" + $day + "_" + $sKey1.sKey1 + ".pdf"
	Copy-Item -Path $_.Fullname -Destination $newName -WhatIf
}