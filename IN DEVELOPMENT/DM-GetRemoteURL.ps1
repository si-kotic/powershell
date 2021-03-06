#AUTOFORM DM 'WEBSVC'

Function DM-GetRemoteURL {
Param (
$dmServer = "vmdev2k3gold1",
$dmPort = "80",


$username = "admin",
$password = "password",
$appID = "8589934705",
$input1 = "279172876238",
$input2,
$input3,
$input4,
$input5,
[switch]$displayInBrowser
)

IF ($inputs) {Remove-Variable inputs -Force}
$i = 1
$input1,$input2,$input3,$input4,$input5 | ForEach-Object {
	IF ($_) {
		$inputs = "&input" + $i + "=" + $_
		$i++
	}
}

$psk = "tatvotse"
$passwordPreHash = $username + $password
$checksumPreHash = $input1 + $input2 + $input3 + $input4 + $input5 + $psk

$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
$utf8 = new-object -TypeName System.Text.UTF8Encoding
$passwordHash = ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($passwordPreHash))) -replace "-","").toLower()
$checksum = ([System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($checksumPreHash))) -replace "-","").toLower()

$uri = "http://" + $dmServer + ":" + $dmPort + "/pdm/remote.jsp?ID=" + $appID + "&j_username=" + $username + "&j_password=" + $passwordHash + "&input1=" + $input1 + "&checksum=" + $checksum
#Write-Output "URL: " $uri
$result = @{"URL" = $uri}
$result

IF ($displayInBrowser) {
	$IE=new-object -com internetexplorer.application
	$IE.navigate2($uri)
	$IE.visible=$true
}

}