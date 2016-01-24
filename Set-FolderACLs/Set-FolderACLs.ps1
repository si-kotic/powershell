

Function Set-FolderACLs {
Param (
[string]$Source = "BLANK"
)

IF ($Source -eq "BLANK")
{
	Write-Output "YOU MUST PROVIDE SOME PERMISSIONS TO SET!"
}
ELSE
{
	
	$startrow = 0	
	
	$newPerms = Import-Csv $Source
	$total = $newPerms.count -1
	$currentrow = $startrow
	New-Item Temp -Type Directory
	$BlankACL = Get-Acl Temp
	Remove-Item Temp
	
	While ($currentrow -le $total)
	{
		$newACL = $BlankACL
		$propAcl = $newPerms.get($currentrow)
		$FolderName = $propAcl.FolderName
		$FullPath = $propAcl.FullPath
		$uncPath = "\\localhost\" + ($FullPath[0]) + "$" + $FullPath.Substring(2)
		$Owner = $propAcl.Owner
		IF ($Owner -contains "\")
		{
			$domain = $Owner.Split("\")[0]
			$UN = $Owner.Split("\")[1]
		}
		IF ($Owner -contains "@")
		{
			$domain = $Owner.Split("@")[1]
			$UN = $Owner.Split("@")[0]
		}
			$newOwn = new-object System.Security.Principal.NTAccount($domain,$un)
			$newACL.SetOwner($newOwn)
		
		$Ar0 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User0,
			$propAcl.Permissions0,
			$propAcl.ApplyTo0,
			"None",
			$propAcl.Type0
			)
		$newACL.AddAccessRule($Ar0)
		$Ar1 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User1,
			$propAcl.Permissions1,
			$propAcl.ApplyTo1,
			"None",
			$propAcl.Type1
			)
		$newACL.AddAccessRule($Ar1)
		$Ar2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User2,
			$propAcl.Permissions2,
			$propAcl.ApplyTo2,
			"None",
			$propAcl.Type2
			)
		$newACL.AddAccessRule($Ar2)
		$Ar3 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User3,
			$propAcl.Permissions3,
			$propAcl.ApplyTo3,
			"None",
			$propAcl.Type3
			)
		$newACL.AddAccessRule($Ar3)
		$Ar4 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User4,
			$propAcl.Permissions4,
			$propAcl.ApplyTo4,
			"None",
			$propAcl.Type4
			)
		$newACL.AddAccessRule($Ar4)
		$Ar5 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User5,
			$propAcl.Permissions5,
			$propAcl.ApplyTo5,
			"None",
			$propAcl.Type5
			)
		$newACL.AddAccessRule($Ar5)
		$Ar6 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User6,
			$propAcl.Permissions6,
			$propAcl.ApplyTo6,
			"None",
			$propAcl.Type6
			)
		$newACL.AddAccessRule($Ar6)
		$Ar7 = New-Object System.Security.AccessControl.FileSystemAccessRule(
			$propAcl.User7,
			$propAcl.Permissions7,
			$propAcl.ApplyTo7,
			"None",
			$propAcl.Type7
			)
		$newACL.AddAccessRule($Ar7)
		
		Set-Acl -Path $uncPath -AclObject $newACL
		
		$currentrow ++
	}
}



}
