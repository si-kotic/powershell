

Function Extract-JFinderZIPs {
[CmdletBinding(SupportsShouldProcess=$true)]
Param (
[switch]$RetainFilename = $false
)

Get-Childitem | Where {$_.Name -like "*.zip"} | ForEach-Object {
	$infile = $_.FullName
	Set-Location "C:\Program Files\7-Zip\"
	Write-Verbose -Message "EXTRACT ZIP CONTENT TO TEMPUNZIP FOLDER"
	. .\7z.exe e $_.FullName -o"c:\bakinboys\tempunzip\"
	IF ($RetainFilename){
		Write-Verbose -Message "OBTAINING FILENAME FROM PROCESSINGINFO.TXT (PDMSKEY1)"
		$newname = (Select-String -Path C:\bakinboys\tempunzip\ProcessingInfo.txt -Pattern " PDMSKEY1 -> \d+").Line.TrimStart(" PDMSKEY1 -> ")
		IF (!$newname)
		{
			Write-Verbose -Message "OBTAINING FILENAME FROM PROCESSINGINFO.TXT (OLDFILENAME)"
			$newname = (Select-String -Path C:\bakinboys\tempunzip\ProcessingInfo.txt -Pattern "^Subject\s+Unrecognised Input document: [\d|\w]+.pdf").Line.TrimStart("^Subject\s+Unrecognised Input document: ").TrimEnd(".pdf")
		}
		Write-Verbose -Message "SEARCHING FOR DUPLICATE FILES"
		$duplicates = Get-ChildItem C:\bakinboys\unzipped\ | Where {$_.Name -like ($newname + "*.pdf")}
		IF ($duplicates)
		{
			Write-Verbose -Message "DUPLICATES FOUND.  COUNTING DUPLICATES"
			$newname = $newname + "_" + $duplicates.count
		}
		Write-Verbose -Message "SETTING FILENAME"
		$newname = $newname + ".pdf"
		Write-Output $newname
	}
	ELSEIF (!($RetainFilename)){
		Write-Verbose -Message "OBTAINING FILENAME FROM ZIPFILE NAME"
		$newname = $_.name
		Write-Verbose -Message "REMOVING .ZIP FROM FILENAME"
		$newname.TrimEnd(".zip")
		Write-Verbose -Message "ADDING .PDF TO FILENAME"
		$newname = $newname + ".pdf"
	}
	Write-Verbose -Message "RENAMING FILE"
	Rename-Item -Path "C:\bakinboys\tempunzip\Page_0001.PDF" -NewName $newname -Force
	Write-Verbose -Message "MOVING FILE TO UNZIPPED FOLDER"
	Move-Item -Path ("C:\bakinboys\tempunzip\"+$newname) -Destination "C:\bakinboys\unzipped\" -Force
	Write-Verbose -Message "REMOVING LEFTOVER FILES FROM TEMPUNZIP"
	Get-ChildItem -LiteralPath "C:\bakinboys\tempunzip" | ForEach-Object {Remove-Item $_.FullName -force}
	Write-Verbose -Message "REMOVING NEWNAME VARIABLE"
	Remove-Variable newname
} | Out-File c:\bakinboys\process.txt


}







Get-Childitem | Where {$_.Name -like "*.zip"} | ForEach-Object {
	$infile = $_.FullName
	Set-Location "C:\Program Files\7-Zip\"
	. .\7z.exe e $_.FullName -o"c:\Temp\tempunzip\"
	$newname = (Get-Content "c:\Temp\tempunzip\ProcessingInfo.txt")[8].split(":")[1].SubString(1)
	$newname + " ------------------>>> " + $infile | Out-File -FilePath c:\Temp\unzipped\names.txt -Append
		Get-ChildItem -LiteralPath "C:\Temp\tempunzip" | ForEach-Object {Remove-Item $_.FullName -force}
}