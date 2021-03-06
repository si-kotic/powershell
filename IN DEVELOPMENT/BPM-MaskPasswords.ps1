Get-ChildItem Server.log* | ForEach-Object {
	$logName = $_.Name
	($curLog = Get-Content $_) | Out-Null
	($newLog = $curLog -replace "<wsse:Password Type=`"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText`">.*?</wsse:Password>", "<wsse:Password Type=`"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText`">PASSWORDHERE</wsse:Password>") | Out-Null
	$logDir = 'C:\EFS\' + (Get-Date).Year + ("{0:D2}" -f (Get-Date).Month) + ("{0:D2}" -f (Get-Date).Day) + "\"
	IF (!(Test-Path $logDir)) {
		New-Item -Path $logDir -ItemType Directory -Force
	}
	$fullLogName = $logDir + $logName
	$newLog | Out-File $fullLogName -Force
	[GC]::Collect()
}
$sourceDir = $logDir
$zipFileName = "C:\EFS\" + (Get-Item $sourceDir).BaseName + ".zip"
[Reflection.Assembly]::LoadWithPartialName("System.IO.Compression.FileSystem")
$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
[System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,$zipfilename, $compressionLevel, $false)