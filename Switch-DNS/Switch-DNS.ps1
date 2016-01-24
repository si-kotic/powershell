<#
.SUMMARY

Switch between using a pre-configured hosts file or performing DNS lookups from SBS002.

Written by Simon Brown 2014.

#>
Function Set-DNS {
Param (
#[string]$connection = "Local"
[switch]$vpn
)
	IF (!$vpn)
	{
		Remove-Item -Path C:\Windows\System32\drivers\etc\hosts -Force
		Copy-Item -Path C:\Windows\System32\drivers\etc\hosts.original -Destination C:\Windows\System32\drivers\etc\hosts -Force
		Set-Content -Value "original" -Path C:\Windows\System32\drivers\etc\hosts.version -Force
		Write-Output "DNS now configured to automatically lookup DNS values from SBS002."
	}
	ELSEIF ($vpn)
	{
		Remove-Item -Path C:\Windows\System32\drivers\etc\hosts -Force
		Copy-Item -Path C:\Windows\System32\drivers\etc\hosts.vpn -Destination C:\Windows\System32\drivers\etc\hosts -Force
		Set-Content -Value "vpn" -Path C:\Windows\System32\drivers\etc\hosts.version -Force
		Write-Output "DNS now configured to use a static, locally configured hosts file."
	}
}


Function Get-DNS {
$version = Get-Content -Path C:\Windows\System32\drivers\etc\hosts.version
IF ($version -eq "vpn")
{
	Write-Output "DNS is currently set to use a static, locally configured hosts file."
}
ELSEIF ($version -eq "original")
{
	Write-Output "DNS is currently set to automatically lookup DNS values from SBS002."
}
ELSE
{
	Write-Output "Cannot detect current DNS settings, please use Set-DNS to configure your DNS source."
}
}

Function Add-DNS {
Param (
[string]$IP,
[string]$Hostname
)
	$newDNS = "`n	$IP	$Hostname"
	Add-Content -Value $newDNS -Path C:\Windows\System32\drivers\etc\hosts.vpn
	$version = Get-Content -Path C:\Windows\System32\drivers\etc\hosts.version
	IF ($version -eq "vpn")
	{
		Set-DNS -vpn
	}
}