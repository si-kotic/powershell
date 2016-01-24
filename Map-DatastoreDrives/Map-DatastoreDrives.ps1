<#

.SYNOPSIS

Maps all Datastores as Drives to be accessed through PowerCli

Written by Simon Brown (2011).


#>

Function Map-DatastoreDrives {

Get-Datastore -Name CFRS_SCRATCH | New-DatastoreDrive -Name "SCRATCH" -Datastore $_

$DSList = Get-Datastore -Name CFRS_VMFS*

$DriveNum = $DSList.Count

While ($DriveNum -gt 0) {
	$DS = Get-Datastore -Name ("CFRS_VMFS" + $DriveNum + "*")
	New-DatastoreDrive -Name ("VMFS" + $DriveNum) -Datastore $DS
	$DriveNum = ($DriveNum - 1)
}


}

