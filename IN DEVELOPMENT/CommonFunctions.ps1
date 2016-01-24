<#

.SYNOPSIS

Common Functions

#>

Function Get-vmOwnerEmail {
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]$VM
)
#(Select-String -InputObject $VM.notes -Pattern "^*contact=\w*\W\w*.co[.\w*]\w*").Matches.Value.TrimStart("contact=")
(Select-String -InputObject $VM.notes -Pattern "^*contact=\w*\W\w*.co[.\w*]\w*").Matches.Value.Substring(8)
}

Function Get-vmExpirationDate {
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]$VM
)
(Select-String -InputObject $VM.Notes -Pattern "^*expiry_date=[0-3][0-9]/[0-1][0-9]/\d{4}").Matches.Value.TrimStart("expiry_date=")
}

Function Validate-Credentials {
Param (
$user,
$password
)
IF (!$Password -or !$User -or !(Test-Path $Password))
{
	Get-Credential
}
ELSE
{
	$pass = Get-Content $Password | ConvertTo-SecureString
	New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User,$pass
}
}

Function Extract-VMNotes {
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=1)]$VM
)
$vmNotes = (Select-String -InputObject $VM.notes -Pattern "^*contact=\w*\W\w*.co[.\w*]\w*").Matches.Value,
(Select-String -InputObject $VM.Notes -Pattern "^*expiry_date=[0-3][0-9]/[0-1][0-9]/\d{4}").Matches.Value,
(Select-String -InputObject $VM.notes -Pattern "^*purpose='[\w\s]*.?'").Matches.Value,
(Select-String -InputObject $VM.notes -Pattern "^*notes='[\w\s]*.?'").Matches.Value | Foreach {
	IF ($_) {$_} ELSE {""}
}

@{'Owner'=IF ($vmNotes[0] -ne "") {$vmNotes[0].Substring(8)} ELSE {""}
'ExpiryDate'=IF ($vmNotes[1] -ne "") {$vmNotes[1].TrimStart("expiry_date=")} ELSE {""}
'Purpose'=IF ($vmNotes[2] -ne "") {$vmNotes[2].TrimStart("purpose='").TrimEnd("'")} ELSE {""}
'Notes'=IF ($vmNotes[3] -ne "") {$vmNotes[3].TrimStart("notes='").TrimEnd("'")} ELSE {""}
}
}

