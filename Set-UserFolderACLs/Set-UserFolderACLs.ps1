<#

.SYNOPSIS

Set Permissions on all User Home Folders.

Written by Simon Brown (2011).

.DESCRIPTION

The Set-UserFolderACLs function retrieves the permissions from a directory

you specify to use as a template and recursively works it's way through the

User Home Folders setting the permissions to match the template with the

addition of the user who the folder belongs to being given Modify permissions.

.PARAMETER root

Specify the directory which contains the User Home Folders

Leave blank for current working directory.

.PARAMETER template

Create a folder with the specific permissions all user home folders should

have without the specific users.  Specify that folder as your template

(eg. c:\template) for the script to retrieve the ACLs as the basis for your

new permissions.

.PARAMETER norecurse

Specify this switch if you do not wish to alter the permissions on the subfolders

and files within your users home folders.

.PARAMETER path

*OUT OF DATE INFORMATION*

Specify the location where the CSV File (FolderSizes.csv) should be saved

(eg. 'H:\Statistics'). By default the filepath is H:\FolderSizes\FolderSizes.csv

NB:  Please be aware that the directory you select must already exist.

.EXAMPLE


--------------- EXAMPLE 1 -----------------


Get-FolderSizes

FolderName                                                       Size Path
----------                                                       ---- ----



#>
Function Set-UserFolderACLs {
Param (
[string]$Root = (Get-Location).Path,
[string]$Template,
[switch]$NoRecurse,
[string]$Path
)



Out-File "RESET USER HOME FOLDER PERMISSIONS (c) 2011 SIMON BROWN" -FilePath $Path
"Date:" | Out-File -FilePath $Path -Append
Get-Date | Out-File -FilePath $Path -Append

Set-Location $Root

$colRights = [System.Security.AccessControl.FileSystemRights]"DeleteSubdirectoriesAndFiles", "Modify", "Synchronize" 
$InheritanceFlag = [System.Security.AccessControl.InheritanceFlags]::"ContainerInherit", "ObjectInherit"
$PropagationFlag = [System.Security.AccessControl.PropagationFlags]::None 
$objType =[System.Security.AccessControl.AccessControlType]::Allow 


Get-ChildItem | where {$_.Attributes -match "d"} | foreach {
$dir = $_.FullName
$UN = "CAMSFIRE\" + $_.Name
$newACL = Get-Acl $Template

$objACE = New-Object System.Security.AccessControl.FileSystemAccessRule 
    ($UN, $colRights, $InheritanceFlag, $PropagationFlag, $objType) 

$newACL.AddAccessRule($objACE)
$newACL | fl | Out-File -FilePath $Path -Append
Set-Acl -Path $dir -AclObject $newACL | Out-File -FilePath $Path -Append

IF (!($NoRecurse))
{
	Get-ChildItem $dir -Force -Recurse | foreach {
	Set-Acl -Path $_.FullName -AclObject $newACL | Out-File -FilePath $Path -Append
	}
}
}

}

