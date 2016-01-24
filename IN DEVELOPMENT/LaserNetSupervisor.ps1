<#

.SYNOPSIS

Alternative to LaserNet Supervisor.

Includes additional ability to archive logs before restarting
the service.

Written by Simon Brown (2013).

#>
<#
Param (
	[string]$msgTo = 'simonb@efstechnology.com',
	[string]$msgFrom = 'IT@efstechnology.com',
	[string]$msgServer = 'sbs002.aps-cambridge.local',
	[int]$msgPort = 25,
	[int]$logInt = 10,
	[bool]$restart = $true,
	[int]$memory = 200,
	[int]$handles = 500
)#>

##  Settings  ##
	#Mail Settings
	$msgTo = 'simonb@efstechnology.com'
	$msgFrom = 'IT@efstechnology.com'
	$msgServer = 'sbs002.aps-cambridge.local'
	$msgPort = 25 #>
	$msgSubject = "LaserNet Failure"
	$msgBody = @"
	The LaserNet service failed and has recovered.
	
	LaserNet Service Status: $($lnService.Status)
	LaserNet Process Handles: $($lnProcess.handles)
	LaserNet Process Memory Usage: $($lnProcess.ws)
	Last Logged Event:
	$($log[-1])
	Log files backed up to: $logDir\$logArch
"@
	#Minimum Log Interval (mins)
	$logInt = 10
	#Service Stopped Time (mins)
	$serviceStopped = 1
	#Restart Service
	$restart = $true
	#Maximum Memory Usage (MB)
	$memory = 200
	#Maximum Handle Usage
	$handles = 500 #>

##  Process  ##
Set-Location 'C:\ProgramData\EFS Technology\LaserNet v6.6\Default\DataFiles\Computers\'
[xml]$settings = Get-Content "$env:COMPUTERNAME.settings"
IF ($settings.settings.Log.LogDirectory)
{
	$logDir = $settings.settings.Log.LogDirectory.'#text'
}
ELSE
{
	$logDir = "$env:ProgramData\EFS Technology\LaserNet v6.6\Default"
}

Set-Location $logDir
$log = Get-Content LaserNet.lnlog
$lnService = Get-Service | where {$_.Name -like "*LaserNet v6.6*"}
$lnProcess = Get-Process lnService.exe

IF ($lnService.Status -eq "Stopped")
{
	$logArch = "logArchive" + (Get-Date).ToString("yyyyMMddHHmmss")
	New-Item -Name $logArch -ItemType Directory -Force
	Get-ChildItem *.lnlog | Copy-Item -Destination $logArch -Force
	$lnService | Start-Service
	Send-MailMessage -Subject $msgSubject -Body $msgBody -To $msgTo -From $msgFrom -SmtpServer $msgServer -Port $msgPort -Priority High
}
ELSE
{
	IF
	(
		((Get-Date $log[-1].Split(";")[1]) -lt (Get-Date).AddMinutes(-$logInt)) -or
		($lnProcess.Handles -gt $handles) -or
		($lnProcess.WS -gt $memory)
	)
	{
		$logArch = "logArchive" + (Get-Date).ToString("yyyyMMddHHmmss")
		New-Item -Name $logArch -ItemType Directory -Force
		Get-ChildItem *.lnlog | Copy-Item -Destination $logArch -Force
		IF ($lnService.Status -eq "Running")
		{
			$lnService | Restart-Service -Force
		}
		ELSE
		{
			$lnProcess | Stop-Process -Force
			Sleep -Seconds 10
			$lnService | Start-Service
		}
		Send-MailMessage -Subject $msgSubject -Body $msgBody -To $msgTo -From $msgFrom -SmtpServer $msgServer -Port $msgPort -Priority High
	}
	
}



