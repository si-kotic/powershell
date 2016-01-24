<#

.SYNOPSIS

Re-activate specific PDM Users
Written by Simon Brown (2013).

.DESCRIPTION

Use this function to re-activate PDM users.

.PARAMETER pdmuser

Specify the pdm username for the user you wish to re-activate

.PARAMETER serverinstance

Specify the SQL Server instance containing the PDM DB.
By default this value is LOCALHOST\SQLEXPRESS

.PARAMETER db

Specify the name of the PDM DB.  By default this value is AFPDM

.PARAMETER username

Specify the username for accessing the PDM DB.  By default this
value is 'pdm'.

.PARAMETER password

Specuify the password for accessing the PDM DB.  This has a default
value of the default password we use for the pdm user account.

.EXAMPLE

PDM-ReactivateUser -PDMUser joebloggs


#>
Param (
$PDMUser,
$ServerInstance = "LOCALHOST\SQLEXPRESS",
$DB = "AFPDM",
$UserName = "pdm",
$Password = "pdm"
)
Invoke-SQLcmd -ServerInstance $ServerInstance -Database $DB -Username $UserName -Password $Password -Query "UPDATE tblUsers SET type=2 WHERE username='$PDMUser'"
Write-Output "User: $PDMUser has now been re-activated."