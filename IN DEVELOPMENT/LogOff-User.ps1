Function LogOff-User {
Param (
[string]$Computer,
[string]$User
)
IF (!($Computer))
	{Write-Output "You must specify the computer where the user is logged on"}
IF (!($User))
	{Write-Output "You must specify a user to log off"}
IF ($User -and $Computer)
{
	$userSession = & "c:\windows\system32\qwinsta.exe" $User /server:$Computer
	$userSession[1][40..45] | ForEach-Object {
		IF ($_ -ne " ") {$sessionID = $sessionID + $_}
	}
	& "logoff" $sessionID /Server:$Computer /V
}
}