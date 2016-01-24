<#

.SYNOPSIS

Returns the sizes of subfolders of the current working directory or

a directory specified.

Written by Simon Brown (2011).

.DESCRIPTION

The Get-FolderSizes function returns the Folder Name, Size (MB) and full

Path of all subfolders from the current working directory.  If the 

StartDirectory paramter has been specified, the function will display

this information for all subfolders of the specified folder.

.PARAMETER startdirectory

Specify the directory for which to retreive statistics for.

Leave blank for current working directory.

.PARAMETER sort

Use this parameter to sort the output by file size.  You must specify

whether it is ascending or descending order.

.PARAMETER export

Specify whether or not to output the result to a CSV file

.PARAMETER path

Specify the location where the CSV File (FolderSizes.csv) should be saved

(eg. 'H:\Statistics'). By default the filepath is H:\FolderSizes\FolderSizes.csv

NB:  Please be aware that the directory you select must already exist.

.EXAMPLE


--------------- EXAMPLE 1 -----------------


Get-FolderSizes

FolderName                                                       Size Path
----------                                                       ---- ----
# Areas for Deletion #                                              0 \\filesvr01\user250\# Areas for Dele...
alan.brown                                           97.1399936676025 \\filesvr01\user250\alan.brown
Amanda.Shepherd                                       49.220645904541 \\filesvr01\user250\Amanda.Shepherd
andrew.jarvis                                        100.046549797058 \\filesvr01\user250\andrew.jarvis
andy.jones                                         0.0713911056518555 \\filesvr01\user250\andy.jones
Ankita.Parmar                                        12.7094736099243 \\filesvr01\user250\Ankita.Parmar
ann.read                                             55.0693922042847 \\filesvr01\user250\ann.read
anna.castagliuolo                                                   0 \\filesvr01\user250\anna.castagliuolo
barbara.russell                                      160.987396240234 \\filesvr01\user250\barbara.russell
bruce.parcell                                        199.190982818604 \\filesvr01\user250\bruce.parcell
carl.pardon                                          209.684685707092 \\filesvr01\user250\carl.pardon
charlotte.dale                                       21.3990211486816 \\filesvr01\user250\charlotte.dale
christine.stewart                                    70.0788803100586 \\filesvr01\user250\christine.stewart


--------------- EXAMPLE 2 -----------------

Get-FolderSizes -Export -Path C:\Temp

FolderName                                                       Size Path
----------                                                       ---- ----
# Areas for Deletion #                                              0 \\filesvr01\user250\# Areas for Dele...
alan.brown                                           97.1399936676025 \\filesvr01\user250\alan.brown
Amanda.Shepherd                                       49.220645904541 \\filesvr01\user250\Amanda.Shepherd
andrew.jarvis                                        100.046549797058 \\filesvr01\user250\andrew.jarvis
andy.jones                                         0.0713911056518555 \\filesvr01\user250\andy.jones
Ankita.Parmar                                        12.7094736099243 \\filesvr01\user250\Ankita.Parmar
ann.read                                             55.0693922042847 \\filesvr01\user250\ann.read
anna.castagliuolo                                                   0 \\filesvr01\user250\anna.castagliuolo
barbara.russell                                      160.987396240234 \\filesvr01\user250\barbara.russell
bruce.parcell                                        199.190982818604 \\filesvr01\user250\bruce.parcell
carl.pardon                                          209.684685707092 \\filesvr01\user250\carl.pardon
charlotte.dale                                       21.3990211486816 \\filesvr01\user250\charlotte.dale
christine.stewart                                    70.0788803100586 \\filesvr01\user250\christine.stewart

Results exported to C:\temp\FolderSizes.csv

This time the table has been output to the file foldersizes.csv in the

folder C:\temp which can be opened and manipulated in Excel or used to

generate statistics and graphs in other applications.


#>
Function Get-FolderSizes {
Param (
[string]$StartDirectory = (Get-Location).Path,
[ValidateSet("","Ascending","Descending")][string]$Sort,
[switch]$Export,
[string]$Path
)

$table = New-Object system.Data.DataTable “User Folder Sizes”

$col1 = New-Object system.Data.DataColumn FolderName,([string])
$col2 = New-Object system.Data.DataColumn Size,([decimal])
$col3 = New-Object system.Data.DataColumn Path,([string])

$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)

$StartDir = Get-Item $StartDirectory

Get-ChildItem $StartDir -Force | ForEach-Object {
[UInt64]$size = 0
$Folder = $_.Name
$curPath = $_.FullName

Get-ChildItem $_ -Recurse -Force | Foreach-Object {$size = $size + $_.Length}

$row = $table.NewRow()

$row.FolderName = $Folder
$row.Size = $size / 1MB
$row.Path = $curPath

$table.rows.add($row)
}

If ($Path -eq "")
{
	$FullPath = "C:\Temp\FolderSizes.csv"
}
Else
{
	$FullPath = ($Path + "\FolderSizes.csv")
}

IF ($Export -eq $true)
{
	Write-Host "Results exported to " $FullPath
	$table | Select-Object FolderName,Size,Path | Export-Csv -Path $FullPath
	Import-Csv $FullPath | Sort-Object -Property Size -Descending | ft -auto -wrap
}
ELSE{
	IF ($Sort -eq "Ascending")
	{
		$table | Sort-Object -Property Size
	}
	ELSEIF ($Sort -eq "Descending")
	{
		$table  | Sort-Object -Property Size -Descending
	}
	ELSE
	{
	$table
	}
}
}