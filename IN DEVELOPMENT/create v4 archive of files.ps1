Get-Content E:\files.txt | ForEach-Object {
	$curFile = "C:\" + $_
	$curPath = "C:\" + $_.SubString(0,22)
	If (!(Test-Path $curPath)) {
			New-Item $curPath -ItemType Directory -Force
		}
	Copy-Item -Path C:\ARCHIVE\2000\05\08\11\one.tif -Destination $curFile
}


Get-Content E:\files.txt | ForEach-Object {
	IF (!(Test-Path $curFile)) {
	Write-Output "False"
	}
}