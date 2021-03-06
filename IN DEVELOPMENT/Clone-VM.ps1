


Function Clone-VM {
Param (
$sourceVM,
$destinationVM,
$destinationPath
)
$vmHost = "vs002.aps-cambridge.local"
$ds = "VirtualMachineArchive"
$folder = "Internal Test Machines"
$customSpecification = "Clone VM"
New-VM -Name $destinationVM -VM $sourceVM -VMHost $vmHost -Datastore $ds -Location $Folder -OSCustomizationSpec $customSpecification
Remove-Variable alive
Do {$alive = Test-Connection $destinationVM}
Until ($alive)
Do {$newVM = Get-VM $destinationVM}
Until ($newVM.PowerState -eq "PoweredOff")
New-PSDrive -Name "vmArchive" -Root \ -PSProvider VimDatastore -Datastore (Get-Datastore $ds) -Scope global
Copy-DatastoreItem -Item "vmArchive:\$destinationVM\" -Destination $destinationPath -Recurse -Force
Remove-VM -VM $destinationVM -DeletePermanently
}



New-DatastoreDrive -Name "vmArchive" -Datastore (Get-Datastore $ds)


Clone-VM -sourceVM "vm-dev-docstore" -destinationVM "vm-dev-docstore-clone" -destinationPath "C:\tmp\"