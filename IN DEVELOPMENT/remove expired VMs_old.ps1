
#Std SMTP Settings
$smtpServer = "sbs001.aps-cambridge.local"
$msgPort = 25
$msgFrom = "IT@EFSTechnology.com"

#Admin User (to retain permissions)
$adminUser = "APS-CAMBRIDGE\admingl"
$adminEmail = "IT@efstechnology.com"

#VMware details (I suggest using a service account so we can identify tasks executed by this script in the VMware logs)
$vmUser = "SiB"
$vmPassword = "charlie1"
$vmServer = "192.168.100.21"

#Connect to VMware Server
Connect-VIServer -Server $vmServer -User $vmUser -Password $vmPassword

#Main Process
Get-VM | Where Notes -ne "" | ForEach-Object {
	$expDateString = $_.Notes.Substring(0,10)
	$expDate = Get-Date $expDateString
	$curDate = Get-Date (Get-Date).ToShortDateString()
	$ownerEmail = $_.Notes.Substring(11)
	$VM = $_.Name
	$msgSubject = "$VM is close to expiration date!"
	$msgBody = "The VM named $VM is scheduled to expire on $expDateString.  If this machine is still required, please contact IT to organise extending this expiration date.  If you do not do this, the VM will be removed automatically."
	$msgBody1 = "The VM named $VM is scheduled to expire tomorrow.  If this machine is still required, please contact IT to organise extending this expiration date.  If you do not do this, the VM will be removed automatically."
	IF (($expDateString -match "[0-3][0-9]/[0-1][0-9]/\d\d\d\d") -and ($ownerEmail -match "\w*@efstechnology.com"))
	{
		IF (($expDate -eq $curDate.AddDays(-7)) -and ($_.PowerState -eq "PoweredOff"))
		{
			Remove-VM -DeletePermanently -VM $_ -WhatIf
		}
		ELSEIF ($expDate -le $curDate)
		{
			Shutdown-VMGuest -VM $_ -WhatIf
			Get-VIPermission -Entity $_ | Where-Object Principal -ne $adminUser | Remove-VIPermission -WhatIf
		}
		ELSEIF ($expDate -eq $curDate.AddDays(1))
		{
			Send-MailMessage -To $ownerEmail -Subject $msgSubject -Body $msgBody1 -SmtpServer $smtpServer -From $msgFrom
		}
		ELSEIF ($expDate -eq $curDate.AddDays(7))
		{
			Send-MailMessage -To $ownerEmail -Subject $msgSubject -Body $msgBody -SmtpServer $smtpServer -From $msgFrom
		}
		ELSEIF ($expDate -eq $curDate.AddDays(14))
		{
			Send-MailMessage -To $ownerEmail -Subject $msgSubject -Body $msgBody -SmtpServer $smtpServer -From $msgFrom
		}
	}
	ELSE
	{
#		Write-Output "The VM, $_, does not contain a valid expiration date or owner."
#		Write-Output "Please check the notes for the VM."
		Send-MailMessage -To $adminEmail -Subject "A Problem was encountered with the VM $_." -Body "The VM, $_, does not contain a valid expiration date or owner." -SmtpServer $smtpServer -From $msgFrom
	}
}