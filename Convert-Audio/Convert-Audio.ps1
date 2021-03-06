Function Convert-Audio {
	Param (
		$inputFile
	)
	$originalWorkingDirectory = $PWD
	$inputFileObj = Get-Item $inputFile
	$outputFile = $inputFileObj.Directory.FullName + "\" + $inputFileObj.BaseName + ".mp3"
	Set-Location "C:\Utilities\ffmpeg-r26400-swscale-r32676-mingw32-static\bin"
	& .\ffmpeg.exe -i $inputFileObj.FullName -ab 320k $outputFile
	Set-Location $originalWorkingDirectory
}