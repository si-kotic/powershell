

$sourceDir = ""
$jfPickupDir = ""
$jfProcessedDir = ""
$backupDir = ""

$jfPickupContent = Get-ChildItem $jfPickupDir

IF (!$jfPickupContent)
{
	Get-ChildItem $jfProcessedDir | ForEach-Object {
		Move-Item -Path $_.FullName -Destination $backupDir -Force
	}
}

IF ($jfPickupContent.Count -lt 100)
{
	(Get-ChildItem $sourceDir)[0..999] | ForEach-Object {
		Move-Item -Path $_.FullName -Destination $jfPickupDir -Force
	}
}