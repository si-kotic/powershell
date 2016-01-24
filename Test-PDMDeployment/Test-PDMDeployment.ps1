<#

#>
Function Test-PDMDeployment {
Param (
[switch]$Restart
)

$Service = (Get-Service | Where {$_.Name -like "*PDM*"})[-1].Name
$curVer = $Service.Substring(21,5)

$ProcessorInfo = Get-WmiObject -Class Win32_Processor
If ($ProcessorInfo.DataWidth -eq "32")
{
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-*.Final\standalone\deployments\"
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-*.Final\standalone\deployments\"
}

IF ((Test-Path ($PDMLocation + "pdm_app_module.ear.failed")) -or (Test-Path ($PDMLocation + "pdm_app_module.ear.undeployed")))
{
	Write-Output "PDM Deployment Failed"
	Write-Output "Backing up failed deployment file..."
	$dateFolder = Get-Date | ForEach-Object {[string]$_.Year + [string]$_.Month + [string]$_.Day}
	New-Item -Path $PDMLocation -Name $dateFolder -ItemType Directory
	Move-Item -Path ($PDMLocation + "pdm_app_module.ear.failed") -Destination ($PDMLocation + $dateFolder) -Force
	Move-Item -Path ($PDMLocation + "pdm_app_module.ear.undeployed") -Destination ($PDMLocation + $dateFolder) -Force
	IF ($Restart)
	{
		Write-Output "Re-attempting PDM Deployment..."
		Get-Service | Where-Object {$_.Name -eq $Service} | Restart-Service -Force
	}
}
ELSE
{
	Write-Output "PDM is already successfully deployed"
}
}