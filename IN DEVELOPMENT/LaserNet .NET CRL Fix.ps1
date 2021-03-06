Set-Location C:\Windows\Microsoft.NET\Framework64\
$runtimeSetting = @'
<runtime>
	<generatePublisherEvidence enabled="false" />
</runtime>
'@

If (Test-Path ".\v2.0.50727\CONFIG\machine.config")
{
	($conf = Get-Content ".\v2.0.50727\CONFIG\machine.config") | Out-Null
	($conf.replace("<runtime/>",$runtimeSetting)) | Set-Content ".\v2.0.50727\CONFIG\machine.config"
	Write-Output "The file C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config has been updated so .NET applications no longer look up the Certificate Revocation List."
}
Else
{
	Write-Output "The file C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\machine.config does not exist!  No changes have been made."
}

If (Test-Path ".\v4.0.30319\CONFIG\machine.config")
{
	($conf = Get-Content ".\v4.0.30319\CONFIG\machine.config") | Out-Null
	($conf.replace("<runtime/>",$runtimeSetting)) | Set-Content ".\v4.0.30319\CONFIG\machine.config"
	Write-Output "The file C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config does not exist!  No changes have been made."
}
Else
{
	Write-Output "The file C:\Windows\Microsoft.NET\Framework64\v4.0.30319\CONFIG\machine.config has been updated so .NET applications no longer look up the Certificate Revocation List."
}