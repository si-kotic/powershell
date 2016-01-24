<#

.SYNOPSIS

Query VMs, their power state, the VM owners and expiration dates.

Written by Simon Brown (2013)

.DESCRIPTION

This script queries all VMs and returns their Name, Power State,

VM owners and expiration dates (as set in the notes field).  A

summary e-mail is then sent to IT.  If you don't pass credentials

to the script, or the password file does not exist, you will be

prompted for them.

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

#SMTP settings
$smtpServer = "sbs002"
$msgPort = 25
$msgFrom = "simonb@efstechnology.com"

#Reporting email address
$adminEmail = "it@efstechnology.com"

#VMware settings
$vmServer = "vs002"
IF (!$vmPassword -or !$vmUser -or !(Test-Path $vmPassword))
{
	$vmCredentials = Get-Credential
}
ELSE
{
	$pass = Get-Content $vmPassword | ConvertTo-SecureString
	$vmCredentials = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $vmUser,$pass
}
#$vmUser = "username"
#$vmPassword = "****"

#Email
$msgSubject = 'Virtual Machine Expiration Summary'
$msgBody = 'Please find below the summary of Virtual Machine expirations and power states:'

## CONFIGURATION END ##

#Connect to VMware Server
Connect-VIServer -Server $vmServer -Credential $vmCredentials

#Create Table
$table = New-Object system.Data.DataTable “FolderACLs”

$col1 = New-Object system.Data.DataColumn vmName,([string])
$col2 = New-Object system.Data.DataColumn powerStatus,([string])
$col3 = New-Object system.Data.DataColumn expiryDate,([string])
$col4 = New-Object system.Data.DataColumn vmOwner,([string])

$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)

#Main Process
Get-VM | ForEach-Object {
	$row = $table.NewRow()
	$row.vmName = $_.Name
	$row.powerStatus = $_.PowerState
	$row.expiryDate = (Select-String -InputObject $_.Notes -Pattern "^*expiry_date=[0-3][0-9]/[0-1][0-9]/\d{4}").Matches.Value.TrimStart("expiry_date=")
	$row.vmOwner = (Select-String -InputObject $_.notes -Pattern "^*contact=\w*\W\w*.co[.\w*]\w*").Matches.Value.TrimStart("contact=")
	$table.rows.add($row)
}

Send-MailMessage -To $adminEmail -From $msgFrom -SmtpServer $smtpServer -Subject $msgSubject -BodyAsHTML ($table | Select-Object vmName,powerStatus,expiryDate,vmOwner | ConvertTo-Html -PreContent $msgBody | Out-String)
<#  CSV Functionality retained in case required.
IF (!(Test-Path "C:\Temp\")) {New-Item -Name "Temp" -Path C:\ -ItemType Directory -Force}
$table | Export-Csv C:\Temp\vmExpirationSummary.csv
$csv = Get-Content C:\Temp\vmExpirationSummary.csv
$csv[1..$csv.Count] | Set-Content C:\Temp\vmExpirationSummary.csv
Send-MailMessage -To $adminEmail -From $msgFrom -SmtpServer $smtpServer -Subject $msgSubject -Body $msgBody -Attachments C:\Temp\vmExpirationSummary.csv
Remove-Item -Path C:\Temp\vmExpirationSummary.csv -Force
#>

#Disconnect from VMware Server
Disconnect-VIServer -Server $vmServer -Confirm:$false