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

#Email
$msgSubject = 'Virtual Machine Expiration Summary'
$msgBody = 'Please find below the summary of Virtual Machine expirations and power states:'
$head = @'
<basefont color=#003399 face="Sans-Serif" />
<style>
  .poweredon {
    background: #ccd7ff;
  }
  .vmtools {
	color: #8b3a3a;
  }
table {
	font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
	font-size: 12px;
	background: #fff;
	margin: 45px;
	width: 100%;
	border-collapse: collapse;
	text-align: left;
	color: #669;
}
table th {
	font-size: 14px;
	font-weight: normal;
	color: #039;
	padding: 10px 8px;
	border-bottom: 2px solid #6678b1;
}
table td {
	padding: 9px 8px 0px 8px;
}
table tbody tr:hover td
{
	color: #009;
}
table tbody .vmtools:hover td
{
	color: #d00;
}
</style>
'@


## CONFIGURATION END ##

#Connect to VMware Server
Connect-VIServer -Server $vmServer -Credential $vmCredentials

#Create Table
$table = New-Object system.Data.DataTable “vmSummary”

$col1 = New-Object system.Data.DataColumn vmName,([string])
$col2 = New-Object system.Data.DataColumn powerStatus,([string])
$col3 = New-Object system.Data.DataColumn expiryDate,([string])
$col4 = New-Object system.Data.DataColumn vmOwner,([string])
$col5 = New-Object system.Data.DataColumn resourcePool,([string])
$col6 = New-Object system.Data.DataColumn purpose,([string])
$col7 = New-Object system.Data.DataColumn notes,([string])
$col8 = New-Object system.Data.DataColumn vmToolsStatus,([string])
$col9 = New-Object system.Data.DataColumn vmToolsVersion,([string])

$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)
$table.columns.add($col6)
$table.columns.add($col7)
$table.columns.add($col8)
$table.columns.add($col9)

#Main Process
Get-VM | ForEach-Object {
	$row = $table.NewRow()
	$row.vmName = $_.Name
	$row.powerStatus = $_.PowerState
	$vmNotes = Extract-VMNotes -VM $_
	$row.vmOwner = $vmNotes.Owner
	$row.expiryDate = $vmNotes.ExpiryDate
	$row.purpose = $vmNotes.Purpose
	$row.notes = $vmNotes.Notes
	$row.resourcePool = $_.ResourcePool.Name
	$row.vmToolsStatus = (Get-View -VIObject $_).Guest.ToolsVersionStatus2.TrimStart("guestTools")
	$row.vmToolsVersion = (Get-View -VIObject $_).Guest.ToolsRunningStatus.TrimStart("guestTools")
	$table.rows.add($row)	
}

#HTML Generation
$html = ""
$table | Where {$_.resourcePool -ne "Resources"} | Group-Object resourcePool | ForEach-Object {
	$html += "<H5>$($_.Name) ($($_.Count))</H5>"
	$html += $_.Group | Select vmName,powerStatus,purpose,expiryDate,vmOwner,notes | ConvertTo-Html -Fragment | Foreach-Object {
		IF ($_.Contains("PoweredOn"))
		{
			IF ($_.Contains("SupportedOld") -or $_.Contains("NotInstalled"))
			{$_.Replace("<tr>","<tr class='poweredon vmtools'>")}
			ELSE
			{$_.Replace("<tr>","<tr class='poweredon'>")}
		}
		ELSE
		{
			IF ($_.Contains("SupportedOld") -or $_.Contains("NotInstalled"))
			{$_.Replace("<tr>","<tr class='vmtools'>")}
			ELSE
			{$_}
		}
	}
	$html += "<br>"
}

ConvertTo-Html -InputObject $null <#-CssUri $css#> -Head $head -Title "Virtual Machine Inventory Summary" -PreContent ("<H4>" + $msgBody + "</H4>") -PostContent $html | Out-File 'C:\temp\Virtual Machine Management\vmOwnersAndExpiry.html'
Send-MailMessage -To $adminEmail -From $msgFrom -SmtpServer $smtpServer -Subject $msgSubject -BodyAsHTML (ConvertTo-Html -InputObject $null <#-CssUri $css#> -Head $head -Title "Virtual Machine Inventory Summary" -PreContent ("<H4>" + $msgBody + "</H4>") -PostContent $html | out-string) -Attachments 'C:\Temp\Virtual Machine Management\vmOwnersAndExpiry.html'

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