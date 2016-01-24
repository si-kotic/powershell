<#

.SYNOPSIS

Allows you to easily set the logging level and database timeout

for PDM Server 7.x.x and above.

Written by Simon Brown (2012).

.DESCRIPTION

Use this tool to change the logging level between DEBUG and INFO

and to change the database timeout period.  By default it is 90

seconds.

.PARAMETER logginglevel

Use this parameter to specify that you want to set the logging

level, then specify info or debug.  You will be informed if the

logging level is already set to the level specified.

.PARAMETER databasetimeout

Use this parameter to specify that you want to set the database

timeout period, then specify the length of time you wish PDM to

wait while it tries to connect to the database.  You will be

informed if the timeout period is already said to the time

specified.

#>

Function Set-PDM {
Param (
#[switch]$Debug,
#[switch]$Info,
[string]$LoggingLevel = $false,
[string]$DatabaseTimeout = $false
)

Write-Verbose -Message "GET VERSION NUMBER FROM SERVICES LIST"
$ver = (Get-Service | Where {$_.Name -like "AutoFORM PDM Archive*"})[-1].Name.Substring(21,5)
Write-Verbose -Message "GET PROCESSOR INFORMATION"
$ProcessorInfo = Get-WmiObject -Class Win32_Processor
If ($ProcessorInfo.DataWidth -eq "32")
{
	Write-Verbose -Message "32 BIT PROCESSOR DETECTED"
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $ver + "\jboss-as-*.Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	Write-Verbose -Message "64 BIT PROCESSOR DETECTED"
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-*.Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
}
Write-Verbose -Message "SET LOCATION TO $PDMLOCATION"
Set-Location $PDMLocation

IF ($LoggingLevel -ne $false)
{
	IF (($LoggingLevel -ne "debug") -and ($LoggingLevel -ne "info"))
	{
		Write-Verbose -Message "LOGGING LEVEL SPECIFIED INCORRECTLY"
		Write-Output "LoggingLevel can only be set to 'debug' or 'info'"
	}
	ELSE
	{
		Write-Verbose -Message "FIND GENERAL EFS LOGGING IN SETTINGS FILE"
		$line = Select-String -Path .\standalone.xml -Pattern "^\s*<logger category=\Wcom.efstech\W>"
		Write-Verbose -Message "READ SETTINGS FILE"
		$original = Get-Content .\standalone.xml
		IF ($original[$line.LineNumber] -match "DEBUG")
		{
			IF ($LoggingLevel -eq "debug")
			{
				Write-Host "PDM logging level is already set to 'DEBUG'"
			}
			ELSEIF ($LoggingLevel -eq "info")
			{
				Write-Verbose -Message "REPLACE DEBUG WITH INFO"
				$newline = $original[$line.LineNumber].Replace("DEBUG","INFO")
				Write-Verbose -Message "WRITE SETTINGS FILE UP TO LOGGING SETTINGS"
				Set-Content .\standalone.xml $original[0..($line.LineNumber-1)]
				Write-Verbose -Message "WRITE LOGGING LINE IN SETTINGS FILE"
				Add-Content .\standalone.xml $newline
				Write-Verbose -Message "WRITE REMAINDER OF SETTINGS FILE"
				Add-Content .\standalone.xml $original[($line.LineNumber+1)..($original.length)]
				Write-Host "Logging Level changed to 'INFO'"
			}
		}
		ELSEIF ($original[$line.LineNumber] -match "INFO")
		{
			IF ($LoggingLevel -eq "debug")
			{
				Write-Verbose -Message "REPALCE INFO WITH DEBUG"
				$newline = $original[$line.LineNumber].Replace("INFO","DEBUG")
				Write-Verbose -Message "WRITE SETTINGS FILE UP TO LOGGING SETTINGS"
				Set-Content .\standalone.xml $original[0..($line.LineNumber-1)]
				Write-Verbose -Message "WRITE LOGGING LINE IN SETTINGS FILE"
				Add-Content .\standalone.xml $newline
				Write-Verbose -Message "WRITE REMAINDER OF SETTINGS FILE"
				Add-Content .\standalone.xml $original[($line.LineNumber+1)..($original.length)]
				Write-Host "Logging Level changed to 'DEBUG'"
			}
			ELSEIF ($LoggingLevel -eq "info")
			{
			Write-Host "PDM logging level is already set to 'INFO'"
			}
		}
	}
}

Write-Verbose -Message "IS DATABASE TIMEOUT BEING SET?"
IF ($DatabaseTimeout -ne $false)
{
	IF (!($DatabaseTimeout.GetType().Name -eq "Int32"))
	{
		Write-Output "DatabaseTimeout must be an integer"
	}
	ELSE
	{
		Write-Verbose -Message "FIND DATABASE TIMEOUT LINE IN SETTINGS FILE"
		$line = Select-String -Path .\standalone.xml -Pattern "^\s*<deployment-scanner path=\Wdeployments\W relative-to=\Wjboss.server.base.dir\W scan-interval=\W\d{4}\W deployment-timeout=\W\d*\W/>"
		Write-Verbose -Message "READ SETTINGS FILE"
		$original = Get-Content .\standalone.xml
		IF ($line.line.Substring(128) -match $DatabaseTimeout)
		{
			Write-Host "Database Timeout already set to " $DatabaseTimeout
		}
		ELSE
		{
			$newline = ""
			Write-Verbose -Message "CHANGE TIMEOUT SETTINGS TO $DATABASETIMEOUT"
			$line.line[0..127] | Foreach-Object {$newline = $newline + $_}
			$newline = $newline + $DatabaseTimeout
			$line.line[-3..-1] | ForEach-Object {$newline = $newline + $_}
			#$line.line.replace('"\d*"/>$', '"' + $DatabaseTimeout + '"/>$')
				Write-Verbose -Message "WRITE SETTINGS FILE UP TO DATABASE SETTINGS"
			Set-Content .\standalone.xml $original[0..($line.linenumber-2)]
				Write-Verbose -Message "WRITE DATABASE TIMEOUT LINE IN SETTINGS FILE"
			Add-Content .\standalone.xml $newline
				Write-Verbose -Message "WRITE REMAINDER OF SETTINGS FILE"
			Add-Content .\standalone.xml $original[$line.linenumber..$original.length]
			Write-Host "Database Timeout set to " $DatabaseTimeout
		}
	}
}

}