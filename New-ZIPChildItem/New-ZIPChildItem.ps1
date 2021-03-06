Function New-ZIPChildItem {
Param (
$inputFullPath,
$zipFilePath,
$zipFileName
)

		Write-Verbose -Message "INPUTFULLPATH = $inputFullPath"
		Write-Verbose -Message "ZIPFILEPATH = $zipFilePath"
IF (!($inputFullPath -match ":"))
{
	Write-Output "inputFullPath Parameter must be the full path"
}
ELSE
{
	IF (!($zipFilePath -match ":"))
	{
		Write-Output "zipFilePath Parameter must be the full path without the filename"
	}
	ELSE
	{
		Write-Verbose -Message "INPUTFULLPATH = $inputFullPath"
		Write-Verbose -Message "ZIPFILEPATH = $zipFilePath"
		$inputObject = Get-Item $inputFullPath
		IF (!$zipFileName)
		{
			Write-Verbose -Message "zipFileName NOT PROVIDED.  USING inputObject NAME TO CREATE zipFileName"
			$zipFileName = $inputObject.BaseName + ".zip"
		}
		Write-Verbose -Message "ZIPFILENAME = $zipFileName"
		
		Write-Verbose -Message "GETTING FULL ZIP PATH AND FILENAME..."
		$zipFullName = $zipFilePath + $zipFileName
		Write-Verbose -Message "zipFullName = $ZIPFULLNAME"
		<#
		IF (!(Test-Path $zipFullName))
		{
			Write-Verbose -Message "$zipFullName DOES NOT EXIST.  CREATING $zipFullName..."
			New-Item -Path $zipFullName -ItemType File -Force
			Write-Verbose -Message "CONVERTING $zipFullName INTO A COMPRESSED ZIP FILE"
			Set-Content $zipFullName ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
		}
		#>
		<#
		$shellApplication = New-Object -ComObject Shell.Application
		$zipObject = $shellApplication.NameSpace($zipFullName)
		$zipObject.CopyHere($inputFullPath)
		#>
		Add-Type -AssemblyName System.IO.Compression.FileSystem
		$CompressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
		[System.IO.Compression.ZipFile]::CreateFromDirectory($inputFullPath,$zipFullName,$CompressionLevel,$true)
		
	}
}
}




