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