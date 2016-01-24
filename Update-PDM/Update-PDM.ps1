<#

.SYNOPSIS

Upgrade PDM using the specified Installation File.

Written by Simon Brown (2012).

.DESCRIPTION

Use this function to upgrade PDM.  The process copies the installation

file from the location specified to the local PC, backs up the current

PDM installation, copies the Licence, setup.war and client.war files

into the same folder, stops the PDM and JFinder services, installs the

specified version of PDM and compares the old and new standalone.xml

files in case some custom changes had been made.  Finally the services

are started again.

.PARAMETER installer

Specifies the installation file for the new version of PDM.

.EXAMPLE

Update-PDM


#>
Function Update-PDM {
Param (
#[switch]$ReImport = $false,
[Parameter (Mandatory=$true,ValueFromPipeline=$true,Position=1)][string]$Installer
)
Import-Module BitsTransfer
If (!(Test-Path "C:\PDMInstaller"))
{
	New-Item -Path C:\ -Name PDMInstaller -ItemType Directory -Force
}
$Transfer = Start-BitsTransfer -Source $Installer -Destination C:\PDMInstaller -Description "PDM Installation Files" -DisplayName "PDM Upgrade" -Asynchronous

$newver = "AutoFORM PDM Archive "
(Get-Item $Installer).Name[-9..-5] | ForEach-Object {$newver = $newver + $_}
$ver = (Get-Service | Where {$_.Name -like "*PDM*"})[-1].Name


Set-Location (Get-Item $Installer).PSParentPath
Copy-Item -Path ".\pdm*.ear" -Destination C:\PDMInstaller -Force

###  Stop Services ###
Write-Host "Stopping Services..."
Get-Service | Where {$_.Name -eq "JFinder"} | Stop-Service
Get-Service | Where {$_.Name -eq $ver} | Stop-Service
Get-Service | Where {$_.Name -eq $ver} | Set-Service -StartupType Disabled

$ProcessorInfo = Get-WmiObject -Class Win32_Processor

If ($ProcessorInfo.DataWidth -eq "32")
{
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\"
	#$MQLocation = "C:\Program Files\Sun\MessageQueue3\bin\"
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\"
	#$MQLocation = "C:\Program Files (x86)\Sun\MessageQueue3\bin\"
}

If (!(Test-Path "C:\PDMBackup"))
{
	New-Item -Path C:\ -Name PDMBackup -ItemType Directory -Force
}

Write-Host "Backing up PDM Folder..."
Set-Location $PDMLocation
$now = Get-Date
$backupLocation = "C:\PDMBackup\" + $now.Year + $now.Month + $now.Day
Get-ChildItem | Where {$_.PSIsContainer -and $_.name -eq ("server_" + $ver.Substring(21,5))} | ForEach-Object {
	Copy-Item -Path $_.FullName -Destination $backupLocation -Recurse -Force
}

Set-Location ("Server_" + $ver.substring(21,5) + "\jboss*\standalone")
Copy-Item -Path ".\configuration\licence.lic" -Destination C:\PDMInstaller -Force
If (Test-Path ".\deployments\client.war")
{
	Write-Host "Preparing CLIENT.WAR for re-implementation..."
	Copy-Item -Path ".\deployments\client.war" -Destination C:\PDMInstaller -Force
}
ElseIf (!(Test-Path ".\deployments\client.war"))
	{Write-Host "No CLIENT.WAR file for deployment"}
If (Test-Path ".\deployments\setup.war")
{
	Write-Host "Preparing SETUP.WAR for re-implementation..."
	Copy-Item -Path ".\deployments\setup.war" -Destination C:\PDMInstaller -Force
}
ElseIf (!(Test-Path ".\deployments\setup.war"))
	{Write-Host "No SETUP.WAR file for deployment"}

Write-Host "Checking that PDM Installation files are ready to begin..."
While (($Transfer.JobState -eq "Transferring") -or ($Transfer.JobState -eq "Connecting"))
{
	Sleep -Seconds 1
}
Switch($Transfer.JobState)
{
	"Transferred" {Complete-BitsTransfer -BitsJob $Transfer}
	"Error" {$Transfer | Format-List}
}

Write-Host "Installing PDM..."
Set-Location C:\PDMInstaller
Invoke-Command -ScriptBlock {(. (Get-Item $Installer.Split("\")[-1]))}
Write-Host "Press any key to continue once the PDM installation wizard has finished..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown,AllowCtrlC") #Waits for key input to unpause script.

Write-Host "Comparing the old PDM Configuration with the new one..."
#$OldConfig = Get-Content "C:\PDMBackup\Server*\jboss*\standalone\configuration\standalone.xml"
#$NewConfig = Get-Content "$PDMLocation\Server*\jboss*\standalone\configuration\standalone.xml"
$OldConfig = Get-Content ($backupLocation + "\Server_" + $ver.SubString(21) + "\jboss-as-*\standalone\configuration\standalone.xml")
$NewConfig = Get-Content ($PDMLocation + "\Server_" + $newver.SubString(21) + "\jboss-as-*\standalone\configuration\standalone.xml")
Compare-Object -ReferenceObject $OldConfig -DifferenceObject $NewConfig

###  Start Services  ###
Write-Host "Starting Services..."
Get-Service | Where {$_.Name -eq $newver} | Start-Service
Get-Service | Where {$_.Name -eq "JFinder"} | Start-Service





















}