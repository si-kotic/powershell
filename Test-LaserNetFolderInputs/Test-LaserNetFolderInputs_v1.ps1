

Function Test-LaserNetFolderInputs {
Param (
[Parameter(Mandatory=$true,Position=1)][string]$source,
[Parameter(Mandatory=$true)][string]$destination0,
[Parameter(Mandatory=$true)][string]$destination1,
[int]$breakpoint = 1000,
[int]$sleeptime = 600,
[switch]$WhatIf
)

$count = 0
$sleepstatement = "Sleeping for " + $sleeptime + " seconds..."

IF (!(Test-Path $source)) {New-Item $source -ItemType "Directory" -Force}
IF (!(Test-Path $destination0)) {New-Item $destination0 -ItemType "Directory" -Force}
IF (!(Test-Path $destination1)) {New-Item $destination1 -ItemType "Directory" -Force}

Get-ChildItem $source | ForEach-Object {
	IF ([bool]!($count%2))
	{
		$destination = $destination0 + $_.Name
	}
	ELSE
	{
		$destination = $destination1 + $_.Name
	}
	IF ($WhatIf -eq $True)
	{
		Move-Item $_.FullName -Destination $destination -Force -WhatIf
	}
	ELSE
	{
		Move-Item $_.FullName -Destination $destination -Force
	}
	$count++
	IF ($count -eq $breakpoint)
	{
		While ([bool](Get-ChildItem $destination0) -or [bool](Get-ChildItem $destination1))
		{
			Sleep -Milliseconds 500
		}
		$count = 0
	}
	
}

}