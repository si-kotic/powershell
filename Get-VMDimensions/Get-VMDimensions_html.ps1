<#

.SYNOPSIS

Returns Details of Virtual Machines running in the Cluster

Written by Simon Brown (2011).

.DESCRIPTION

The Get-VMDimensions function returns the Name and Operating system of

Virtual Machines defined in the Cluster along with the number of CPUs,

quantity of RAM (in MBs) and Hard Drive sizes (in GBs) along with other

useful information.

.PARAMETER vm

Specify the Virtual Machine you wish to retreive statistics for.

Leave blank for all Virtual Machines.

.PARAMETER resourceallocation

This switch limits the view to just allocated resources such as vCPUs,

RAM (MBs), HDD (GBs) and Total Datastore Consumtiopn (GBs).

.PARAMETER network

This switch limits the view to just networking information.

.PARAMETER status

This switch displays information on VMTools, Snapshots, Alarms and the

running state of the machine.

.PARAMETER export

Specify whether or not to output the result to a CSV file

.PARAMETER path

Specify the location where the CSV File (VirtualMachines.csv) should be saved

(eg. 'H:\Statistics'). By default the filepath is H:\VMware\VirtualMachines.csv

NB:  Please be aware that the directory you select must already exist.

.EXAMPLE


--------------- EXAMPLE 1 -----------------


Get-VMDimensions

VMName    vCPUs RAM  HDD0 HDD1 HDD2 TotalDSConsumed OS                                        Datastore     Host
------    ----- ---  ---- ---- ---- --------------- --                                        ---------     ----
VM01      1     128  8                              Linux 2.6x                                Int SAS Store ESX01
VM02      1     2048 40                             Microsoft Windows Server 2008 R2 (64-bit) Int SAS Store ESX01
VM03      2     6144 0    60   40   100             Ubuntu 10.1                               Int SAS Store ESX01
VM04      1     2048 20                             Windows 7 (64-bit)                        Int SAS Store ESX01
VM05      1     2048 40                             Microsoft Windows Server 2008 R2 (64-bit) Int SAS Store ESX01


--------------- EXAMPLE 2 -----------------

Get-VMDimensions -Export -Path C:\Temp

VMName    vCPUs RAM  HDD0 HDD1 HDD2 TotalDSConsumed OS                                        Datastore     Host
------    ----- ---  ---- ---- ---- --------------- --                                        ---------     ----
VM01      1     128  8                              Linux 2.6x                                Int SAS Store ESX01
VM02      1     2048 40                             Microsoft Windows Server 2008 R2 (64-bit) Int SAS Store ESX01
VM03      2     6144 0    60   40   100             Ubuntu 10.1                               Int SAS Store ESX01
VM04      1     2048 20                             Windows 7 (64-bit)                        Int SAS Store ESX01
VM05      1     2048 40                             Microsoft Windows Server 2008 R2 (64-bit) Int SAS Store ESX01

VM Dimensions exported to  C:\temp\VirtualMachines.csv

This time the table has been output to the file virtualmachines.csv in the

folder C:\temp which can be opened and manipulated in Excel or used to

generate statistics and graphs in other applications.


#>
Function Get-VMDimensions {
Param (
[string]$VM = "*",
[switch]$ResourceAllocation,
[switch]$Network,
[switch]$Status,
[switch]$Export,
[String]$Path
)

$table = New-Object system.Data.DataTable “VM Dimensions”

$col1 = New-Object system.Data.DataColumn VMName,([string])
$col2 = New-Object system.Data.DataColumn vCPUs,([decimal])
$col3 = New-Object system.Data.DataColumn RAM,([decimal])
$col4 = New-Object system.Data.DataColumn HDD0,([decimal])
$col5 = New-Object system.Data.DataColumn HDD1,([decimal])
$col6 = New-Object system.Data.DataColumn HDD2,([decimal])
$col7 = New-Object system.Data.DataColumn HDD3,([decimal])
$col8 = New-Object system.Data.DataColumn HDD4,([decimal])
$col9 = New-Object system.Data.DataColumn TotalDSConsumed,([decimal])
$col10 = New-Object system.Data.DataColumn OS,([string])
$col11 = New-Object system.Data.DataColumn Datastore,([string])
$col12 = New-Object system.Data.DataColumn Host,([string])
$col13 = New-Object system.Data.DataColumn IPAddress0,([string])
$col14 = New-Object system.Data.DataColumn IPAddress1,([string])
$col15 = New-Object system.Data.DataColumn IPAddress2,([string])
$col16 = New-Object system.Data.DataColumn IPAddress3,([string])
$col17 = New-Object system.Data.DataColumn HostName,([string])
$col18 = New-Object system.Data.DataColumn State,([string])
$col19 = New-Object system.Data.DataColumn VMToolsInst,([string])
$col20 = New-Object system.Data.DataColumn VMToolsVersion,([string])
$col21 = New-Object system.Data.DataColumn VMToolsRunning,([string])
$col22 = New-Object system.Data.DataColumn Alarms,([string])
$col23 = New-Object system.Data.DataColumn Snapshots,([string])
$col24 = New-Object system.Data.DataColumn ResourcePool,([string])
$col25 = New-Object system.Data.DataColumn Network1,([string])
$col26 = New-Object system.Data.DataColumn Network2,([string])
$col27 = New-Object system.Data.DataColumn Network3,([string])
$col28 = New-Object system.Data.DataColumn Network4,([string])

$table.columns.add($col1)
$table.columns.add($col2)
$table.columns.add($col3)
$table.columns.add($col4)
$table.columns.add($col5)
$table.columns.add($col6)
$table.columns.add($col7)
$table.columns.add($col8)
$table.columns.add($col9)
$table.columns.add($col10)
$table.columns.add($col11)
$table.columns.add($col12)
$table.columns.add($col13)
$table.columns.add($col14)
$table.columns.add($col15)
$table.columns.add($col16)
$table.columns.add($col17)
$table.columns.add($col18)
$table.columns.add($col19)
$table.columns.add($col20)
$table.columns.add($col21)
$table.columns.add($col22)
$table.columns.add($col23)
$table.columns.add($col24)
$table.columns.add($col25)
$table.columns.add($col26)
$table.columns.add($col27)
$table.columns.add($col28)

$VMQuery = Get-VM $VM

$VMQuery | ForEach-Object {

$row = $table.NewRow()

$row.VMName = $_.Name
$row.vCPUs = $_.numCPU
$row.RAM = $_.MemoryMB

	#Checking for Multiple Drives#

	$HDDCheck = 0
	$HDDCheck = (get-harddisk -vm $_.name).Count
	
	IF ($HDDCheck -gt 0)
	{
		$row.HDD0 = (get-harddisk -vm $_.name)[0].capacitykb / 1mb
		$row.HDD1 = (get-harddisk -vm $_.name)[1].capacitykb / 1mb
		$row.HDD2 = (get-harddisk -vm $_.name)[2].capacitykb / 1mb
		$row.HDD3 = (get-harddisk -vm $_.name)[3].capacitykb / 1mb
		$row.HDD4 = (get-harddisk -vm $_.name)[4].capacitykb / 1mb
	}
	Else
	{
		$row.HDD0 = (get-harddisk -vm $_.name).capacitykb / 1mb
		$row.HDD1 = 0
		$row.HDD2 = 0
		$row.HDD3 = 0
		$row.HDD4 = 0
	}

$row.TotalDSConsumed = ($row.HDD0 + $row.HDD1 + $row.HDD2 + $row.HDD3 + $row.HDD4)
$row.OS = $_.guest.osfullname
$row.Datastore = (Get-Datastore -VM $_.Name).Name
$row.Host = $_.VMHost.Name

	#Checking Number of IP Addresses#

	IF ($_.Guest.IPAddress.Count -ge 2)
	{
		$row.IPAddress0 = $_.guest.ipaddress[0]
		$row.IPAddress1 = $_.guest.ipaddress[1]
		$row.IPAddress2 = $_.guest.ipaddress[2]
		$row.IPAddress3 = $_.guest.ipaddress[3]
	}
	ELSE
	{
		$row.IPAddress0 = $_.guest.ipaddress[0]
	}

$row.HostName = $_.guest.hostname
$row.State = $_.guest.state

	#Checking For VMTools#

	IF ((Get-View -VIObject $_).config.tools.toolsversion -eq "0")
	{
		$row.VMToolsInst = "Not Installed"
		$row.VMToolsVersion = "Not Installed"
		$row.VMToolsRunning = "Not Installed"
	}
	Else
	{
		$row.VMToolsInst = "Installed"
		IF ((Get-View -VIObject $_).guest.toolsversionstatus -eq "guestToolsCurrent")
		{
			$row.VMToolsVersion = "Current"
		}
		ELSE
		{
			$row.VMToolsVersion = "Out of Date"
		}
		IF ((Get-View -VIObject $_).guest.toolsrunningstatus -eq "guestToolsRunning")
		{
		$row.VMToolsRunning = "Running"
		}
		ELSE
		{
			$row.VMToolsRunning = "Not Running"
		}
	}

	#Checking For Triggered Alarms#

	$AlarmCheck = (Get-View -VIObject $_).TriggeredAlarmState.Count
	IF ($AlarmCheck -eq 0)
	{
		$row.Alarms = "No"
	}
	Else
	{
		$row.Alarms = "Yes"
	}

	#Checking for Snapshot#

	$SnapCheck = 0
	$SnapCheck = (Get-View -VIObject $_).Snapshot.CurrentSnapshot.Type
	IF ($SnapCheck -eq "VirtualMachineSnapshot")
	{
		$row.Snapshots = "Yes"
	}
	Else
	{
		$row.Snapshots = "No"
	}

$row.ResourcePool = (Get-ResourcePool | Where {$_.Id -eq (Get-View -VIObject $_).ResourcePool}).Name

	#Checking for Multiple Adapters#

	$IPCheck = 0
	$IPCheck = (get-NetworkAdapter -vm $_).Count
	
	IF ($IPCheck -ge 2)
	{
		$row.Network1 = (get-NetworkAdapter -vm $_)[0].NetworkName
		$row.Network2 = (Get-NetworkAdapter -VM $_)[1].NetworkName
		$row.Network3 = (Get-NetworkAdapter -VM $_)[2].NetworkName
		$row.Network4 = (Get-NetworkAdapter -VM $_)[3].NetworkName
	}
	Else
	{
		$row.Network1 = (get-NetworkAdapter -vm $_).NetworkName
	}


$table.rows.add($row)

}

$TotalCPU = $table | Measure-Object -Property "vCPUs" -Sum
$TotalRAM = $table | Measure-Object -Property "RAM" -Sum
$TotalStorage = $table | Measure-Object -Property "TotalDSConsumed" -Sum

$row = $table.NewRow()

$row.VMName = "Totals"
$row.vCPUs = $TotalCPU.sum
$row.RAM = $TotalRAM.sum
$row.TotalDSConsumed = $TotalStorage.sum
$table.rows.add($row)


If ($Path -eq "")
{
	$FullPath = "H:\VMware\VirtualMachines.csv"
}
Else
{
	$FullPath = ($Path + "\VirtualMachines.csv")
}


IF (($Export -eq $false) -and ($ResourceAllocation -eq $false) -and ($network -eq $false) -and ($Status -eq $false))
{
	#$table | ft -auto -wrap
	$table | ConvertTo-Html | Out-File 'C:\Temp\Virtual Machine Management\vms.html'
}

IF ($Export -eq $true)
{
	$table | Export-Csv $FullPath;
	Write-Host "VM Dimensions exported to " $FullPath
	IF (($ResourceAllocation -eq $false) -and ($Network -eq $false) -and ($Status -eq $false))
	{
		Import-Csv $FullPath | ft -auto -wrap
	}
}

IF ($ResourceAllocation -eq $true)
{
	$table | ft VMName,vCPUs,RAM,HDD0,HDD1,HDD2,HDD3,HDD4,TotalDSConsumed -auto -wrap
}

IF ($Network -eq $true)
{
	$table | ft VMName,IPAddress0,IPAddress1,IPAddress2,IPAddress3,HostName,Network1,Network2,Network3,Network4 -auto -wrap
}
IF ($Status -eq $true)
{
	$table | ft VMName,State,VMToolsInst,VMToolsVersion,Alarms,Snapshots
}


}

