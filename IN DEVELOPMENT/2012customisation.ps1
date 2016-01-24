<#

.SYNOPSIS

Configuration/Customisation of Server 2012 as the vmware
customisation function is incompatible with 2012.

Written by Simon Brown (2013)

For timezones, use this:
http://msdn.microsoft.com/en-us/library/ms912391(v=winembedded.11).aspx

#>

Param (
[string]$OwnerName,
[string]$OwnerOrganisation,
[string]$ComputerName,
[string]$DomainName,
[string]$ProductKey,
$TimeZone,
$IPAddress,
$IPGateway,
$IPdns0
)

<#Order:
**SYSPREP!!!!!! Use this script to populate answer file.

Confirm user specified settings
NewSID?
Registration Info (Name/Org)
Computer Name
ProductKey
Time Zone
Network
Domain
Update Antivirus.
Check for updates??
Remove Sysprep .xml file

NB.  Look into providing Admin credentials, rebooting, auto-login and resume script!
#>

$scriptPath = (Split-Path $MyInvocation.MyCommand.Path)

Write-Output "Review the Summary and confirm that you would like to continue."
Write-Output @"
Owner Name: $OwnerName
Owner Organisation: $OwnerOrganisation
Computer Name: $ComputerName
Timezone: $TimeZone
Network: $Network"
IP Address: $IPAddress
Join Domain: $DomainName
"@
Write-Output "Are you sure you want to customise this Virtual Machine with the above settings?"
Write-Output "[Y] Yes  [N] No"; $answer = $Host.UI.RawUI.ReadKey("IncludeKeyDown"); Write-Output "`r"
IF ($answer.character -eq "y")
{
	$AdminCredentials = Get-Credential
	[xml]$unattend = Get-Content ($scriptPath + "\Server2012std.xml")
	IF ($DomainName)
	{
		$unattend.unattend.settings[1].component[0].Identification.Credentials.Domain = $DomainName
		$unattend.unattend.settings[1].component[0].Identification.Credentials.Password = $AdminCredentials.GetNetworkCredential().Password
		$unattend.unattend.settings[1].component[0].Identification.Credentials.Username = $AdminCredentials.Username
		$unattend.unattend.settings[1].component[0].Identification.JoinDomain = $DomainName
	}
	ELSE
	{
		$unattend.unattend.settings[1].component[0].RemoveAll
	}
	$unattend.unattend.settings[1].component[1].ProductKey = $ProductKey
	$unattend.unattend.settings[1].component[1].RegisteredOrganization = $OwnerOrganisation
	$unattend.unattend.settings[1].component[1].RegisteredOwner = $OwnerName
	$unattend.unattend.settings[1].component[1].TimeZone = $TimeZone
	$unattend.unattend.settings[1].component[1].ComputerName = $ComputerName
	IF ($IPAddress)
	{
		$unattend.unattend.settings[2].component[0].Interfaces.Interface.UnicastIpAddresses.IpAddress."#Text" = $IPAddress
		$unattend.unattend.settings[2].component[0].Interfaces.Interface.Routes.Route.NextHopAddress = $IPGateway
		$unattend.unattend.settings[2].component[1].Interfaces.Interface.DNSServerSearchOrder.IPAddress."#Text" = $IPdns0
	}
	ELSE
	{
		$unattend.unattend.settings[2].component[0].Interfaces.Interface.Ipv4Settings.DhcpEnabled = $true.ToString()
		$unattend.unattend.settings[2].component[0].Interfaces.Interface.UnicastIpAddresses.RemoveAll()
		$unattend.unattend.settings[2].component[0].Interfaces.Interface.Routes.RemoveAll()
		$unattend.unattend.settings[2].component[1].RemoveAll()
	}
	$unattend.Save($scriptPath + "\Server2012std.xml")
	
	#Script the running of SysPrep here.
}
ELSE
{
	Write-Output "User has chosen to cancel...blah blah..."
}
