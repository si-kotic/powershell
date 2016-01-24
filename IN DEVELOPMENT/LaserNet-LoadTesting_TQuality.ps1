Function LaserNet-LoadTesting {
[CmdletBinding(SupportsShouldProcess=$true)]
Param (
#[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]  << ONLY WORKS IN V3!
[string]$Source = '',
#[Parameter(Mandatory=$true, Position=2)]  << ONLY WORKS IN V3!
[string]$Destination0 = '',
[string]$Destination1 = $destination0,
[string]$Destination2 = $destination0,
[string]$Destination3 = $destination1,
[string]$Destination4 = $destination0,
[int]$Breakpoint = 1000,
[string]$OutputPrinter
)

IF ($Source -eq '')
{
	Read-Host "Please provide a source directorty to use"
}

IF ($Destination0 -eq '')
{
	Read-Host "Please provide a destination directory to use"
}

Write-Verbose -Message "CHECK WHETHER OR NOT source AND destination0 END WITH '\'. IF THEY DO NOT, THE CHARACTER IS ADDED."
IF ($source[-1] -ne "\") {$source = $source + "\"}
IF ($destination0[-1] -ne "\") {$destination0 = $destination0 + "\"}
Write-Verbose -Message "SET count TO 0 AND sleeptime TO 500ms"
$count = 0
$tCount = 0
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
			Write-Verbose -Message "PERFORM COPY PROCECSS TO destination."
			Copy-Item $_.FullName -Destination $destination -Force
		$dir++
		Write-Verbose -Message "INCREMENT count."
		$count++
		IF ($count -eq $breakpoint)
		{
			<#$tCount = $tCount + $count
			Write-Verbose -Message "count HAS REACHED THE DEFINED breakpoint. SCRIPT PAUSES UNTIL SPECIFIED DESTINATION(S) ARE EMPTY."
			While ((Get-WMIObject -Class win32_printJob | where {$_.Name.Split(",")[0] -eq $OutputPrinter}).Count -lt $tCount)
			{
				Sleep -Milliseconds $sleeptime
			}#>
			$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $OutputPrinter}
			$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
			$endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
			While ($endTime -gt (Get-Date).AddSeconds(-60))
			{
				Start-Sleep -Seconds 60
				$printJobs = Get-WmiObject -Class Win32_PrintJob | Where {$_.Name.Split(",")[0] -eq $OutputPrinter}
				$lastJob = ($printJobs | Sort-Object TimeSubmitted -Descending)[0]
				$endTime = $lastJob.ConvertToDateTime($lastJob.TimeSubmitted)
			}
			(Get-WMIObject -Class win32_printJob | where {$_.Name.Split(",")[0] -eq $OutputPrinter}).Delete()
			Write-Verbose -Message "RESET count TO 0."
			$count = 0
			[GC]::Collect()
		}
	}


}