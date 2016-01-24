Function Get-EFSServices {
Param (
[switch]$LaserNet62,
[switch]$LaserNet65,
[switch]$LaserNet66,
[switch]$PDM,
[switch]$JFinder
)

IF ($LaserNet62)
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

