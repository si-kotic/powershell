﻿#	QUERY VARIOUS PDM SETTINGS

<#

.SYNOPSIS

Allows you to easily query the logging level and database timeout

for PDM Server 7.x.x and above.

Written by Simon Brown (2012).

.DESCRIPTION

Use this tool to query the logging level and to change the 

database timeout period.

#>

Function Get-PDM {

$startLocation = Get-Location
$ver = (Get-Service | Where {$_.Name -like "AutoFORM PDM Archive*"})[-1].Name.Substring(21,5)
Write-Verbose -Message "GET PROCESSOR INFORMATION"
$ProcessorInfo = Get-WmiObject -Class Win32_Processor
If ($ProcessorInfo.DataWidth -eq "32")
{
	Write-Verbose -Message "32 BIT PROCESSOR DETECTED"
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $ver + "\jboss-as-" + $ver + ".Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
	IF ($ver -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-7.1.1.Final\standalone\configuration\"
	}
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	Write-Verbose -Message "64 BIT PROCESSOR DETECTED"
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-" + $ver + ".Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
	IF ($ver -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-7.1.1.Final\standalone\configuration\"
	}
}
Write-Verbose -Message "SET LOCATION TO $PDMLOCATION"
Set-Location $PDMLocation

Write-Verbose -Message "READ SETTINGS FILE"
$settings = Get-Content .\standalone.xml
Write-Verbose -Message "READ LOGGING LEVEL FROM SETTINGS"
$LoggingLevel = $settings[(Select-String -Path .\standalone.xml -Pattern "^\s*<logger category=\Wcom.efstech\W>").LineNumber].Split('"')[1]
Write-Verbose -Message "READ DB CONNECTION TIMEOUT FROM SETTINGS"
$DatabaseTimeout = $settings[(Select-String -Path .\standalone.xml -Pattern "^\s*<deployment-scanner path=\Wdeployments\W relative-to=\Wjboss.server.base.dir\W scan-interval=\W\d{4}\W deployment-timeout=\W\d*\W/>").LineNumber-1].Split('"')[-2]
Write-Verbose -Message "READ HTTP PORT FROM SETTINGS"
$HTTPPort = $settings[(Select-String -Path .\standalone.xml -Pattern "^\s*<socket-binding name=\Whttp\W port=\W\d*\W/>").LineNumber-1].Split('"')[-2]
Write-Verbose -Message "READ HTTPS PORT FROM SETTINGS"
$HTTPSPort = $settings[(Select-String -Path .\standalone.xml -Pattern "^\s*<socket-binding name=\Whttps\W port=\W\d*\W/>").LineNumber-1].Split('"')[-2]

Write-Verbose -Message "CREATE TABLE"
$table = New-Object system.Data.DataTable “PDM Configuration”
Write-Verbose -Message "DEFINE COLUMNS"
$col1 = New-Object system.Data.DataColumn HTTP_Port,([string])
$col2 = New-Object system.Data.DataColumn HTTPS_Port,([decimal])
$col3 = New-Object system.Data.DataColumn Logging_Level,([string])
$col4 = New-Object system.Data.DataColumn Database_Timeout,([string])
$col5 = New-Object system.Data.DataColumn Install_Path,([string])
Write-Verbose -Message "ADD COLUMNS TO TABLE"
$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)
Write-Verbose -Message "CREATE ROW"
$row = $table.NewRow()
Write-Verbose -Message "ASSIGN VALUES TO FIELDS IN ROW"
$row.HTTP_Port = $HTTPPort
$row.HTTPS_Port = $HTTPSPort
$row.Logging_Level = $LoggingLevel
$row.Database_Timeout = $DatabaseTimeout
$row.Install_Path = $PDMLocation
Write-Verbose -Message "ADD ROW TO TABLE"
$table.rows.add($row)

Write-Output "Autoform PDM $ver Configuration:"
$table | FL
Set-Location $startLocation
}


#	SET VARIOUS PDM SETTINGS

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
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $ver + "\jboss-as-" + $ver + ".Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
	IF ($ver -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-7.1.1.Final\standalone\configuration\"
	}
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	Write-Verbose -Message "64 BIT PROCESSOR DETECTED"
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-" + $ver + ".Final\standalone\configuration\"
	Write-Verbose -Message "CHANGE PDMLOCATION TO $pdmlocation"
	IF ($ver -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $ver + "\jboss-as-7.1.1.Final\standalone\configuration\"
	}
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



#	UTILITY FOR LOAD TESTING LASERNET

<#

.SYNOPSIS

Facilitates the testing of LaserNet using Input Folders.

Written by Simon Brown (2012).

.DESCRIPTION

The Test-LaserNetFolderInputs function automatically moves all

files from a specified source to the specified destination(s)

ready for LaserNet to pick them up and process them.

The function can be optimised for slower systems or simply to

simulate different sized batches of documents.

.PARAMETER source

A mandatory parameter to specify the folder containing the

files to be moved and processed by LaserNet.  This parameter

accepts inputs from the pipeline in the form of a folderpath

as a string.

.PARAMETER destination0

A mandatory parameter to specify the folder which LaserNet uses

as an input folder and also the destination to move the source

files to.

.PARAMETER destination1

An optional parameter to specify the folder which LaserNet uses

as an input folder and also the destination to move the source

files to.

.PARAMETER destination2

An optional parameter to specify the folder which LaserNet uses

as an input folder and also the destination to move the source

files to.

.PARAMETER destination3

An optional parameter to specify the folder which LaserNet uses

as an input folder and also the destination to move the source

files to.

.PARAMETER destination4

An optional parameter to specify the folder which LaserNet uses

as an input folder and also the destination to move the source

files to.

.PARAMETER breakpoint

Specify the number of files to be moved before the process pauses

and waits for LaserNet to pickup all the files in the destination

folders.  Once all destination folders are empty; the process

resumes with the moving of files.

.PARAMETER whatif

Specify this option to simulate the running of the function and

output which objects would be affected by the command and what

changes would be made to those objects.  No changes are actually

made.

.PARAMETER verbose

Specify this option to turn on the verbose output mode.  This will

display a description of what the function is doing at each step of

the way.  It makes troubleshooting a doddle!

.EXAMPLE

 Test-LaserNetFolderInputs -Source C:\Grab -Destination0 C:\Lasernet\Input

.EXAMPLE

 (Get-ChildItem -Recurse | Where-Object {$_.FullName -eq "Grab"}).FullName | Test-LaserNetFolderInputs -Destination0 C:\Lasernet\Input

.EXAMPLE

 Test-LaserNetFolderInputs -Source C:\Temp\F_JFINDER -Destination0 C:\NEWLOCATION0 -Destination1 c:\newlocation1 -Destination2 C:\NEWLOCATION2 -Destination3 C:\Newlocation3 -Breakpoint 10 -verbose

VERBOSE: CHECK WHETHER OR NOT source AND destination0 END WITH '\'. IF THEY DO NOT, THE CHARACTER IS ADDED.
VERBOSE: SET count TO 0 AND sleeptime TO 500ms
VERBOSE: CHECKING IF destination0 IS A VALID DIRECTORY.  IF NOT, IT IS CREATED.
VERBOSE: CHECKING IF ONLY destination0 HAS BEEN SET.
VERBOSE: CHECKING IF ONLY destination0 AND destination1 HAVE BEEN SET.
VERBOSE: CHECKING IF ONLY C:\NEWLOCATION0\, destination1 AND destination2 HAVE BEEN SET.
VERBOSE: CHECKING IF ONLY destination0, destination1, destination2 AND destination3 HAVE BEEN SET.
VERBOSE: CHECK WHETHER OR NOT destination1, destination2 AND destination3 END WITH '\'. IF THEY DO NOT, THE CHARACTER IS ADDED.
VERBOSE: CHECKING IF destination1, destination2 AND destination3 ARE VALID DIRECTORIES.  IF NOT, THEY ARE CREATED.
VERBOSE: SET destination TO destination0
VERBOSE: PERFORM MOVE PROCECSS TO destination.
VERBOSE: INCREMENT count.
VERBOSE: SET destination TO destination1
VERBOSE: PERFORM MOVE PROCECSS TO destination.
VERBOSE: INCREMENT count.
VERBOSE: SET destination TO destination0
VERBOSE: PERFORM MOVE PROCECSS TO destination.
VERBOSE: INCREMENT count.
VERBOSE: SET destination TO destination1
VERBOSE: PERFORM MOVE PROCECSS TO destination.
VERBOSE: INCREMENT count.
VERBOSE: count HAS REACHED THE DEFINED breakpoint. SCRIPT PAUSES UNTIL SPECIFIED DESTINATION(S) ARE EMPTY.


#>
Function Test-LaserNetFolderInputs {
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)][string]$Source,
[Parameter(Mandatory=$true, Position=2)][string]$Destination0,
[string]$Destination1 = $destination0,
[string]$Destination2 = $destination0,
[string]$Destination3 = $destination1,
[string]$Destination4 = $destination0,
[int]$Breakpoint = 1000,
[switch]$WhatIf
)

Write-Verbose -Message "CHECK WHETHER OR NOT source AND destination0 END WITH '\'. IF THEY DO NOT, THE CHARACTER IS ADDED."
IF ($source[-1] -ne "\") {$source = $source + "\"}
IF ($destination0[-1] -ne "\") {$destination0 = $destination0 + "\"}
Write-Verbose -Message "SET count TO 0 AND sleeptime TO 500ms"
$count = 0
$Sleeptime = 500
#$sleepstatement = "Sleeping for " + $sleeptime + " seconds..."
Write-Verbose -Message "CHECKING IF destination0 IS A VALID DIRECTORY.  IF NOT, IT IS CREATED."
IF (!(Test-Path $destination0)) {New-Item $destination0 -ItemType "Directory" -Force}

	Write-Verbose -Message "CHECK WHETHER ALL DESTINATION VARIABLES END WITH '\'. IF THEY DO NOT, THE CHARACTER IS ADDED."
	IF ($destination1[-1] -ne "\") {$destination1 = $destination1 + "\"}
	IF ($destination2[-1] -ne "\") {$destination2 = $destination2 + "\"}
	IF ($destination3[-1] -ne "\") {$destination3 = $destination3 + "\"}
	IF ($destination4[-1] -ne "\") {$destination4 = $destination4 + "\"}
	Write-Verbose -Message "CHECKING IF ALL DESTINATION VARIABLES ARE VALID DIRECTORIES.  IF NOT, THEY ARE CREATED."
	IF (!(Test-Path $destination1)) {New-Item $destination1 -ItemType "Directory" -Force}
	IF (!(Test-Path $destination2)) {New-Item $destination2 -ItemType "Directory" -Force}
	IF (!(Test-Path $destination3)) {New-Item $destination3 -ItemType "Directory" -Force}
	IF (!(Test-Path $destination4)) {New-Item $destination4 -ItemType "Directory" -Force}
	$dir = 0
	Get-ChildItem $source | ForEach-Object {
		IF ($dir -eq 0)
		{
			Write-Verbose -Message "SET destination TO destination0"
			$destination = $destination0 + $_.Name
		}
		ELSEIF ($dir -eq 1)
		{
			Write-Verbose -Message "SET destination TO destination1"
			$destination = $destination1 + $_.Name
		}
		ELSEIF ($dir -eq 2)
		{
			Write-Verbose -Message "SET destination TO destination2"
			$destination = $destination2 + $_.Name
		}
		ELSEIF ($dir -eq 3)
		{
			Write-Verbose -Message "SET destination TO destination3"
			$destination = $destination3 + $_.Name
		}
		ELSEIF ($dir -eq 4)
		{
			Write-Verbose -Message "SET destination TO destination4"
			$destination = $destination4 + $_.Name
			$dir = -1
		}
		IF ($WhatIf -eq $True)
		{
			Write-Verbose -Message "PERFORM MOVE PROCECSS TO destination WITH -WhatIf PARAMETER SET."
			Move-Item $_.FullName -Destination $destination -Force -WhatIf
		}
		ELSE
		{
			Write-Verbose -Message "PERFORM MOVE PROCECSS TO destination."
			Move-Item $_.FullName -Destination $destination -Force
		}
		$dir++
		Write-Verbose -Message "INCREMENT count."
		$count++
		IF ($count -eq $breakpoint)
		{
			Write-Verbose -Message "count HAS REACHED THE DEFINED breakpoint. SCRIPT PAUSES UNTIL SPECIFIED DESTINATION(S) ARE EMPTY."
			While ([bool](Get-ChildItem $destination0) -or [bool](Get-ChildItem $destination1))
			{
				Sleep -Milliseconds $sleeptime
			}
			Write-Verbose -Message "RESET count TO 0."
			$count = 0
		}
	}


}


#	LIST ALL EFS RELATED SERVICES AND THEIR STATUS

Function Get-EFSServices {
Param (
[switch]$LaserNet65,
[switch]$LaserNet66,
[switch]$PDM,
[switch]$JFinder
)

IF ($LaserNet6)
{
	Get-Service | where {$_.Name -eq "LaserNet v6"}
}
IF ($LaserNet65)
{
	Get-Service | where {$_.Name -like "*LaserNet v6.5*"}
}
IF ($LaserNet66)
{
	Get-Service | where {$_.Name -like "*LaserNet v6.6*"}
}
ELSEIF ($PDM)
{
	Get-Service | where {$_.Name -like "*PDM*"}	
}
ELSEIF ($JFinder)
{
	Get-Service | where {$_.Name -like "*JFinder*"}	
}
ELSE
{
	Get-Service | where {$_.Name -like "*PDM*" -or $_.Name -like "*LaserNet*" -or $_.Name -like "*JFinder*"}
}
}

#	RESET JFINDER MESSAGE QUEUE

<#

.SYNOPSIS

Reset's the Sun Message Queue used by JFinder.

Written by Simon Brown (2011).

.DESCRIPTION

The Reset-JFinderQueue function clears and reset's the Sun Message

Queue used by JFinder.  It includes the option to re-import all previously

failed jobs.

.PARAMETER reimport

Specifies whether or not you wish to re-import all failed jobs.

.EXAMPLE


--------------- EXAMPLE 1 -----------------


Reset-JFinderQueue



#>
Function Reset-JFinderQueue {
Param (
[switch]$ReImport = $false
)

###  Stop Services ###
Get-Service | Where {$_.Name -eq "JFinder"} | Stop-Service
Get-Service | Where {$_.Name -eq "iMQ_Broker"} | Stop-Service

$ProcessorInfo = Get-WmiObject -Class Win32_Processor

If ($ProcessorInfo.DataWidth -eq "32")
{
	$JFinderLocation = "C:\Program Files\AutoFORM\JFinderV2\"
	$MQLocation = "C:\Program Files\Sun\MessageQueue3\bin\ "
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	$JFinderLocation = "C:\Program Files (x86)\AutoFORM\JFinderV2\"
	$MQLocation = "C:\Program Files (x86)\Sun\MessageQueue3\bin\"
}

Set-Location $JFinderLocation\WORK\PICKUP
New-Item -Name BACKUP -ItemType Directory -Force
Get-ChildItem | Where {!$_.PSIsContainer} | ForEach-Object {
	Move-Item -Path $_.FullName -Destination .\BACKUP\ -Force
}

Set-Location $JFinderLocation\WORK\PROCESSED
New-Item -Name BACKUP -ItemType Directory -Force
Get-ChildItem | Where {!$_.PSIsContainer} | ForEach-Object {
	Move-Item -Path $_.FullName -Destination .\BACKUP\ -Force
}
If ($ReImport)
{
	Get-ChildItem -LiteralPath .\BACKUP | Where {$_.Name -like "FPickUp*.zip"} | Foreach-Object {
		$FullName = $_.FullName
		$NewName = $_.Name.Substring(2)
		$NewFullName = $_.PSParentPath + "\" + $NewName
		Rename-Item -Path $_.Name -NewName $NewName -Force}
}

Set-Location $MQLocation
Invoke-Command -ScriptBlock {imqbrokerd.exe -reset messages}

If ($ReImport)
{
	Set-Location $JFinderLocation\WORK\PROCESSED\BACKUP
	Get-ChildItem | Where {$_.Name -like "Pickup*.zip"} | ForEach-Object {
		Move-Item -Path $_.FullName -Destination ..\ -Force}
}

###  Start Services  ###
Get-Service | Where {$_.Name -eq "JFinder"} | Start-Service
Get-Service | Where {$_.Name -eq "iMQ_Broker"} | Start-Service

}



#	TEST PDM DEPLOYMENT STATUS AND RETRY DEPLOYMENT WITH OPTIONAL RESTART

Function Test-PDMDeployment {
Param (
[switch]$Restart
)

$Service = (Get-Service | Where {$_.Name -like "*PDM*"})[-1].Name
$curVer = $Service.Substring(21,5)

$ProcessorInfo = Get-WmiObject -Class Win32_Processor
If ($ProcessorInfo.DataWidth -eq "32")
{
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-" + $curVer + ".Final\standalone\deployments\"
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-" + $curVer + ".Final\standalone\deployments\"
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



#	UPDATE PDM VERSION 7.x.x UPWARDS

<#

.SYNOPSIS

Upgrade PDM using the specified Installation File.

Written by Simon Brown (2011).

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
Get-ChildItem | Where {$_.PSIsContainer -and $_.name -eq ("server_" + $ver.Substring(21,5))} | ForEach-Object {
	Copy-Item -Path $_.FullName -Destination "C:\PDMBackup" -Recurse -Force
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
$OldConfig = Get-Content "C:\PDMBackup\Server*\jboss*\standalone\configuration\standalone.xml"
$NewConfig = Get-Content "$PDMLocation\Server*\jboss*\standalone\configuration\standalone.xml"
Compare-Object -ReferenceObject $OldConfig -DifferenceObject $NewConfig

###  Start Services  ###
Write-Host "Starting Services..."
Get-Service | Where {$_.Name -eq $newver} | Start-Service
Get-Service | Where {$_.Name -eq "JFinder"} | Start-Service

}

#  TEST PDM VERSION 7.x.x DEPLOYMENTS AND UPWARDS

<#

.SYNOPSIS

Allows you to easily query whether or not PDM has successfully

deployed or not.  If not then it backs up the failed deployment

files and re-attempts deployment.  Includes option to restart PDM.

Applies to PDM Server 7.x.x and above.

Written by Simon Brown (2012).

.DESCRIPTION

Use this tool to test for a successful deployment of PDM and

re-deploy if required.

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
	$PDMLocation = "C:\Program Files\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-" + $curVer + ".Final\standalone\deployments\"
	IF ($curVer -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-7.1.1.Final\standalone\deployments\"
	}
}
ElseIf ($ProcessorInfo.DataWidth -eq "64")
{
	$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-" + $curVer + ".Final\standalone\deployments\"
	IF ($curVer -eq "7.1.2")
	{
		Write-Verbose -Message "PDM v7.1.2 INSTALLED; ADJUSTING PDM LOCATION PATH TO ACCOMODATE INCORRECT PATH"
		$PDMLocation = "C:\Program Files (x86)\EFS Technology\PDM\Server_" + $curVer + "\jboss-as-7.1.1.Final\standalone\deployments\"
	}
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