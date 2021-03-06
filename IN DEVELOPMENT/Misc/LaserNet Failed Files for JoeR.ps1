this is the path with the xmls
C:\Deploy\CSTFA 111214\CSTFA

this is the failed pdfs
C:\EFS Technology\EFSHistory\ZylabIMports\CSFTA\Failed\LaserNetFailures

$VerbosePreference = "Continue" #Enable Verbose Logging
$VerbosePreference = "SilentlyContinue" #Disable Verbose Logging


Get-ChildItem "C:\Deploy\CSTFA 111214\CSTFA" | ForEach-Object {
	$fileName = $_.BaseName
	Write-Verbose -Message "fileName = $fileName"
	$newPath = "C:\Deploy\CSTFA 111214\CSTFA\" + $fileName + ".xml"
	Get-ChildItem "C:\EFS Technology\EFSHistory\ZylabIMports\CSFTA\Failed\LaserNetFailures" -Name ($fileName + ".xml") -Recurse | ForEach-Object {
		Write-Verbose -Message ("XML File = " + $_)
		$origPath = ("C:\EFS Technology\EFSHistory\ZylabIMports\CSFTA\Failed\LaserNetFailures\" + $_)
		Write-Verbose -Message $origPath
		Copy-Item -Path $origPath -Destination $newPath -Force -WhatIf
	}
}

