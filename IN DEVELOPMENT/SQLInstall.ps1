
Param (
[ValidateSet("2005", "2008", "2012")]$Version
)

Start-Transcript -Path C:\Scripts\InstallationLog_SQL.log
$Processor = Get-WmiObject -Class Win32_Processor

IF ($Processor.Count)
{
	$DataWidth = $processor[0].DataWidth
	IF ($DataWidth -eq 64)
	{
		$DataWidth = "x64"
		Write-Output "$DataWidth Processor detected"
	}
	ELSEIF ($DataWidth -eq 32)
	{
		$DataWidth = "x86"
		Write-Output "$DataWidth Processor detected"
	}
}
ELSE
{
	$DataWidth = $processor.DataWidth
	IF ($DataWidth -eq 64)
	{
		$DataWidth = "x64"
		Write-Output "$DataWidth Processor detected"
	}
	ELSEIF ($DataWidth -eq 32)
	{
		$DataWidth = "x86"
		Write-Output "$DataWidth Processor detected"
	}
}

####  COPY INSTALLATION MEDIA  ####
New-Item C:\InstallationMedia\SQL\ -ItemType Directory -Force
Sleep -Milliseconds 500
$sqlInstaller = "SQLEXPRESS_" + $Version + "_" + $DataWidth + "_ENU.exe"
$sqlInstallerPath = "\\nas1\IT\Software\Microsoft\SQL Server\" + $sqlInstaller
Start-Job -Name CopySQLInstallationMedia -ScriptBlock {Copy-Item -Path $sqlInstallerPath -Destination C:\InstallationMedia\SQL\ -Force}

Do {Sleep -Seconds 1}
Until ((Get-Job CopySQLInstallationMedia).State -eq "Completed")

####  PRE-REQUISITES  ####
Import-Module ServerManager
Add-WindowsFeature NET-Framework-Core
Remove-Module ServerManager

####  SQL CLI Install - Setup.exe /q /ACTION=Install /FEATURES=SQL /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\Network Service" /SQLSYSADMINACCOUNTS="Administrator" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS  ####
Set-Location C:\InstallationMedia\SQL\
Start-Job -Name SQLInstallation -ScriptBlock {. .\$sqlInstaller /q /ACTION=Install /FEATURES=SQL, SSMS /INSTANCENAME=SQLEXPRESS /SQLSVCACCOUNT="NT AUTHORITY\Network Service" /SQLSYSADMINACCOUNTS="Administrator" /AGTSVCACCOUNT="NT AUTHORITY\Network Service" /IACCEPTSQLSERVERLICENSETERMS}

Do {Sleep -Seconds 1}
Until ((Get-Job SQLInstallation).State -eq "Completed")

####  CREATE SQL DB  ####
$SQLPS = Get-Item ("C:\" + (Get-ChildItem -Path C:\ -Name SQLPS.exe -Recurse))
. $SQLPS
$localhost = Get-Content ENV:ComputerName
Set-Location .\SQL\$localhost
$sqlServer = Get-Item .\SQLEXPRESS
$dbAFPDM = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -ArgumentList $sqlServer, "AFPDM"
$dbAFPDM.Create()

Sleep -Seconds 30

####  ENABLE TCP  ####
$mc = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Wmi.ManagedComputer
$urn = New-Object -TypeName Microsoft.SqlServer.Management.Sdk.Sfc.Urn -ArgumentList "ManagedComputer[@Name='$env:ComputerName']/ServerInstance[@Name='SQLEXPRESS']/ServerProtocol[@Name='Tcp']"
$sqlProtocol = $mc.GetSmoObject($urn)
$sqlProtocol.IsEnabled = $true
$sqlProtocol.Alter()

Foreach ($tcpAddress in $sqlProtocol.ipAddresses) {
 Foreach ($property in $tcpAddress.ipAddressProperties) {
  If ($property.Name -eq "Enabled") {
   $property.Value=[bool]1
   $sqlProtocol.Alter()
  }
  If ($property.Name -eq "TcpPort") {
   $property.Value=1433
   $sqlProtocol.Alter()
  }
 }
}

Get-Service | Where-Object {$_.DisplayName -eq "SQL SERVER (SQLEXPRESS)"} | Restart-Service -Force

####  CREATE SQL USER/LOGIN & ASSIGN RIGHTS  ####
Invoke-SqlCmd -InputFile "C:\Scripts\SQLCreateUser.sql"
exit


<#
IF ($Version -eq "2005")
{
	
}

IF ($Version -eq "2008")
{
	
}

IF ($Version -eq "2012")
{
	
}
#>

Stop-Transcript