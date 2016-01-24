$lan = Get-NetAdapter "Ethernet 2"
$wlan = Get-NetAdapter "Wi-Fi"
if ($lan.Status -eq "UP")
{
	Disable-NetAdapter Wi-Fi -Confirm:$false
}
elseif ($wlan.Status -eq "Disabled")
{
	Enable-NetAdapter Wi-Fi -Confirm:$false
}
