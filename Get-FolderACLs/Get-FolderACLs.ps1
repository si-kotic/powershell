


Function Get-FolderACLs {
Param (
[string]$Root,
[switch]$Recuse,
[string]$FilePath
)

$table = New-Object system.Data.DataTable “FolderACLs”

$col1 = New-Object system.Data.DataColumn FullPath,([string])
$col2 = New-Object system.Data.DataColumn FolderName,([string])
$col3 = New-Object system.Data.DataColumn Owner,([string])
$col4 = New-Object system.Data.DataColumn User0,([string])
$col5 = New-Object system.Data.DataColumn Permissions0,([string])
$col6 = New-Object system.Data.DataColumn Type0,([string])
$col7 = New-Object system.Data.DataColumn ApplyTo0,([string])
$col8 = New-Object system.Data.DataColumn User1,([string])
$col9 = New-Object system.Data.DataColumn Permissions1,([string])
$col10 = New-Object system.Data.DataColumn Type1,([string])
$col11 = New-Object system.Data.DataColumn ApplyTo1,([string])
$col12 = New-Object system.Data.DataColumn User2,([string])
$col13 = New-Object system.Data.DataColumn Permissions2,([string])
$col14 = New-Object system.Data.DataColumn Type2,([string])
$col15 = New-Object system.Data.DataColumn ApplyTo2,([string])
$col16 = New-Object system.Data.DataColumn User3,([string])
$col17 = New-Object system.Data.DataColumn Permissions3,([string])
$col18 = New-Object system.Data.DataColumn Type3,([string])
$col19 = New-Object system.Data.DataColumn ApplyTo3,([string])
$col20 = New-Object system.Data.DataColumn User4,([string])
$col21 = New-Object system.Data.DataColumn Permissions4,([string])
$col22 = New-Object system.Data.DataColumn Type4,([string])
$col23 = New-Object system.Data.DataColumn ApplyTo4,([string])
$col24 = New-Object system.Data.DataColumn User5,([string])
$col25 = New-Object system.Data.DataColumn Permissions5,([string])
$col26 = New-Object system.Data.DataColumn Type5,([string])
$col27 = New-Object system.Data.DataColumn ApplyTo5,([string])
$col28 = New-Object system.Data.DataColumn User6,([string])
$col29 = New-Object system.Data.DataColumn Permissions6,([string])
$col30 = New-Object system.Data.DataColumn Type6,([string])
$col31 = New-Object system.Data.DataColumn ApplyTo6,([string])
$col32 = New-Object system.Data.DataColumn User7,([string])
$col33 = New-Object system.Data.DataColumn Permissions7,([string])
$col34 = New-Object system.Data.DataColumn Type7,([string])
$col35 = New-Object system.Data.DataColumn ApplyTo7,([string])

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
$table.columns.add($col29)
$table.columns.add($col30)
$table.columns.add($col31)
$table.columns.add($col32)
$table.columns.add($col33)
$table.columns.add($col34)
$table.columns.add($col35)


$rootACL = Get-Acl $Root
$topDIR = Get-Item $root


$row = $table.NewRow()
$row.Fullpath = [string]$topDIR.FullName
$row.FolderName = [string]$topDIR.Name
$row.Owner = [string]$RootACL.Owner
	<# Access Rights 0 #>
	$row.User0 = [string]$rootacl.access[0].identityreference.value
	$row.Permissions0 = [string]$rootacl.access[0].filesystemrights
	$row.Type0 = [string]$rootacl.access[0].accesscontroltype
	$row.ApplyTo0 = [string]$rootacl.Access[0].inheritanceflags
	<# Access Rights 1 #>
	$row.User1 = [string]$rootacl.access[1].identityreference.value
	$row.Permissions1 = [string]$rootacl.access[1].filesystemrights
	$row.Type1 = [string]$rootacl.access[1].accesscontroltype
	$row.ApplyTo1 = [string]$rootacl.Access[1].inheritanceflags
	<# Access Rights 2 #>
	$row.User2 = [string]$rootacl.access[2].identityreference.value
	$row.Permissions2 = [string]$rootacl.access[2].filesystemrights
	$row.Type2 = [string]$rootacl.access[2].accesscontroltype
	$row.ApplyTo2 = [string]$rootacl.Access[2].inheritanceflags
	<# Access Rights 3 #>
	$row.User3 = [string]$rootacl.access[3].identityreference.value
	$row.Permissions3 = [string]$rootacl.access[3].filesystemrights
	$row.Type3 = [string]$rootacl.access[3].accesscontroltype
	$row.ApplyTo3 = [string]$rootacl.Access[3].inheritanceflags
	<# Access Rights 4 #>
	$row.User4 = [string]$rootacl.access[4].identityreference.value
	$row.Permissions4 = [string]$rootacl.access[4].filesystemrights
	$row.Type4 = [string]$rootacl.access[4].accesscontroltype
	$row.ApplyTo4 = [string]$rootacl.Access[4].inheritanceflags
	<# Access Rights 5 #>
	$row.User5 = [string]$rootacl.access[5].identityreference.value
	$row.Permissions5 = [string]$rootacl.access[5].filesystemrights
	$row.Type5 = [string]$rootacl.access[5].accesscontroltype
	$row.ApplyTo5 = [string]$rootacl.Access[5].inheritanceflags
	<# Access Rights 6 #>
	$row.User6 = [string]$rootacl.access[6].identityreference.value
	$row.Permissions6 = [string]$rootacl.access[6].filesystemrights
	$row.Type6 = [string]$rootacl.access[6].accesscontroltype
	$row.ApplyTo6 = [string]$rootacl.Access[6].inheritanceflags
	<# Access Rights 7 #>
	$row.User7 = [string]$rootacl.access[7].identityreference.value
	$row.Permissions7 = [string]$rootacl.access[7].filesystemrights
	$row.Type7 = [string]$rootacl.access[7].accesscontroltype
	$row.ApplyTo7 = [string]$rootacl.Access[7].inheritanceflags



$table.rows.add($row)

IF ($Recuse -eq $true)
{
	Get-ChildItem $root | ForEach-Object {
	
	$subACL = Get-Acl $_.FullName
	
	$row = $table.NewRow()
	$row.Fullpath = [string]$_.FullName
	$row.FolderName = [string]$_.Name
	$row.Owner = [string]$subACL.Owner
		<# Access Rights 0 #>
		$row.User0 = [string]$subacl.access[0].identityreference.value
		$row.Permissions0 = [string]$subacl.access[0].filesystemrights
		$row.Type0 = [string]$subacl.access[0].accesscontroltype
		$row.ApplyTo0 = [string]$subacl.Access[0].inheritanceflags
		<# Access Rights 1 #>
		$row.User1 = [string]$subacl.access[1].identityreference.value
		$row.Permissions1 = [string]$subacl.access[1].filesystemrights
		$row.Type1 = [string]$subacl.access[1].accesscontroltype
		$row.ApplyTo1 = [string]$subacl.Access[1].inheritanceflags
		<# Access Rights 2 #>
		$row.User2 = [string]$subacl.access[2].identityreference.value
		$row.Permissions2 = [string]$subacl.access[2].filesystemrights
		$row.Type2 = [string]$subacl.access[2].accesscontroltype
		$row.ApplyTo2 = [string]$subacl.Access[2].inheritanceflags
		<# Access Rights 3 #>
		$row.User3 = [string]$subacl.access[3].identityreference.value
		$row.Permissions3 = [string]$subacl.access[3].filesystemrights
		$row.Type3 = [string]$subacl.access[3].accesscontroltype
		$row.ApplyTo3 = [string]$subacl.Access[3].inheritanceflags
		<# Access Rights 4 #>
		$row.User4 = [string]$subacl.access[4].identityreference.value
		$row.Permissions4 = [string]$subacl.access[4].filesystemrights
		$row.Type4 = [string]$subacl.access[4].accesscontroltype
		$row.ApplyTo4 = [string]$subacl.Access[4].inheritanceflags
		<# Access Rights 5 #>
		$row.User5 = [string]$rootacl.access[5].identityreference.value
		$row.Permissions5 = [string]$rootacl.access[5].filesystemrights
		$row.Type5 = [string]$rootacl.access[5].accesscontroltype
		$row.ApplyTo5 = [string]$rootacl.Access[5].inheritanceflags
		<# Access Rights 6 #>
		$row.User6 = [string]$rootacl.access[6].identityreference.value
		$row.Permissions6 = [string]$rootacl.access[6].filesystemrights
		$row.Type6 = [string]$rootacl.access[6].accesscontroltype
		$row.ApplyTo6 = [string]$rootacl.Access[6].inheritanceflags
		<# Access Rights 7 #>
		$row.User7 = [string]$rootacl.access[7].identityreference.value
		$row.Permissions7 = [string]$rootacl.access[7].filesystemrights
		$row.Type7 = [string]$rootacl.access[7].accesscontroltype
		$row.ApplyTo7 = [string]$rootacl.Access[7].inheritanceflags
	
	$table.rows.add($row)
	}
}


<# NEW ROW TO ADD IN
$row = $table.NewRow()

$table.rows.add($row)
#>


$table | Export-Csv c:\Temp\perms.csv

}