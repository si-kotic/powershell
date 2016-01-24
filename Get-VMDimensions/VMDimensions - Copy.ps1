<#

.SYNOPSIS

Returns Details of all the VMs running in the Cluster

.DESCRIPTION

The Get-VMDimensions function returns the Name and Operating system of all 

Virtual Machines defined in the Cluster along with the number of CPUs,

quantity of RAM (in MBs)and Hard Drive size.

.PARAMETER export

Specify whether or not to output the result to a CSV file [Yes/No]

.PARAMETER path

Specify the location where the CSV File (VirtualMachines.csv) should be saved

(eg. 'H:\Statistics'). By default the filepath is H:\VMware\VirtualMachines.csv

NB:  Please be aware that the directory you select must already exist.

.EXAMPLE

Get-VMDimensions

#>
Function Get-VMDimensions {
Param (
[string]$Export = "No",
[String]$Path
)
$VMName = @{Label="VM Name"; Expression={$_.name}}
$VMOS = @{Label="Operating System"; Expression={$_.guest.osfullname}}
$NumCPU = @{Label="CPUs"; Expression={$_.numCPU}}
$MemoryMB = @{Label="RAM(MB)"; Expression={$_.MemoryMB}}
$HDDSize = @{Label="HDD Size"; Expression={$_.ProvisionedSpaceGB}}
If ($Path -eq "")
{
	$FullPath = "H:\VMware\VirtualMachines.csv"
}
Else
{
	$FullPath = ($Path + "\VirtualMachines.csv")
}
If (($Export -ne "Yes") -and ($Export -ne "No") -and ($Export -ne ""))
{
	Write-Host "Only 'Yes' and 'No' are valid values for the parameter 'Export'"
}
Else
{
	If (($Export -ne "Yes"))
	{
		get-vm | ft $VMName,$NumCPU,$MemoryMB,$HDDSize,$VMOS -auto -wrap
	}
	Else
	{
		get-vm | Select-Object $VMName,$NumCPU,$MemoryMB,$HDDSize,$VMOS | Export-Csv $FullPath;
		Import-Csv $FullPath | ft -auto -wrap
		Write-Host "VM Dimensions exported to " $FullPath
	}
}
}