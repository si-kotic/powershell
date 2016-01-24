<#

.SYNOPSIS

Query VM owners and expiration dates.

Written by Simon Brown (2013)

.DESCRIPTION

This script queries the VM owners and expiration dates (as set in the

notes field) and informs the owner if the expiration date is less than

14 days in the future.  If you don't pass credentials to the script,

or the password file does not exist, you will be prompted for them.

NB.  CommonFunctions.ps1 must be in the same directory as this script in

order for it to function!

.PARAMETER vmuser

Enter the username required to connect to the VMware Server in plain

text.

.PARAMETER vmpassword

Specify a file containing a secure, encrypted copy of the password

required to connect to the VMware server.  To generate this file run

the following command:

Read-Host -AsSecureString | ConvertFrom-SecureString | Out-File C:\securestring.txt

.EXAMPLE

& ".\Get-VMExpirationSummary.ps1" -vmUser username -vmPassword C:\securestring.txt

.EXAMPLE

& ".\vm status summary.ps1"

#>

## CONFIGURATION START ##
Param (
$vmUser,
$vmPassword
)

#Load Common Functions
. ((Split-Path $MyInvocation.MyCommand.Path) + "\CommonFunctions.ps1")

#SMTP settings
$smtpServer = "sbs002"
$msgPort = 25
$msgFrom = "simonb@efstechnology.com"

#Reporting email address
$adminEmail = "simonb@efstechnology.com"

#VMware settings
$vmServer = "vs002"
$vmCredentials = Validate-Credentials -user $vmUser -password $vmPassword

#Admin user to retain permissions
$adminUser = "root"

#Warning email
$msgSubject = 'Your virtual machine "$VM" is about to expire'
$msgBody = 'The virtual machine "$VM" is scheduled to expire on $expDateString.  Please contact IT if it is still required, otherwise it it will be retired.'

## CONFIGURATION END ##


#Connect to VMware Server
Connect-VIServer -Server $vmServer -Credential $vmCredentials #-User $vmUser -Password $vmPassword

#Main Process
Get-ResourcePool | where {($_.Name -ne "Production machines") -and ($_.Name -ne "Resources")} | Get-VM | Where Notes -ne "" | ForEach-Object {
	$vmNotes = Extract-VMNotes -VM $_
	$expDateString = $vmNotes.ExpiryDate
	$expDate = Get-Date $expDateString
	$curDate = Get-Date (Get-Date).ToShortDateString()
	$ownerEmail = $vmNotes.Owner
	$VM = $_.Name
	IF ($expDateString -and $ownerEmail)
	{
		IF ($expDate -le $curDate)
		{
			Shutdown-VMGuest -VM $_ -WhatIf
			Get-VIPermission -Entity $_ | Where-Object Principal -ne $adminUser | Remove-VIPermission -WhatIf
		}
		ELSEIF ($expDate -le $curDate.AddDays(14))
		{
			Send-MailMessage -To $adminEmail -Subject $ExecutionContext.InvokeCommand.ExpandString($msgSubject) -Body $ExecutionContext.InvokeCommand.ExpandString($msgBody) -SmtpServer $smtpServer -From $msgFrom
		}
	}
	ELSE
	{
#		Write-Output "The VM, $_, does not contain a valid expiration date or owner."
#		Write-Output "Please check the notes for the VM."
		Send-MailMessage -To $adminEmail -Subject "A Problem was encountered with the VM $_." -Body "The VM, $_, does not contain a valid expiration date or owner." -SmtpServer $smtpServer -From $msgFrom
	}
}

#Disconnect from VMware Server
Disconnect-VIServer -Server $vmServer -Confirm:$false