Get-Process MSACCESS | ForEach-Object {
$_.CloseMainWindow()
}
Sleep -Seconds 30
FOR ($i=0;$i -eq 5; $++)
{
	$cs = Get-Process MSACCESS
	IF (!$cs) {$i = 5} ELSE {Sleep -Seconds 30}
}
IF ($cs)
{
	$cs | Stop-Process -Force
}

Get-Process MSACCESS | ForEach-Object {$_.CloseMainWindow()}; Sleep -Seconds 30; FOR ($i=0;$i -eq 5; $++) {$cs = Get-Process MSACCESS; IF (!$cs) {$i = 5} ELSE {Sleep -Seconds 30}}; IF ($cs) {$cs | Stop-Process -Force}


ps MSACCESS | %{$_.CloseMainWindow()}; FOR($i=0;$i -eq 5; $++){$cs = Get-Process MSACCESS; IF(!$cs){$i = 5} ELSE {Sleep -Seconds 30}}; IF($cs){$cs|Stop-Process -Force}