<#
.DESCRIPTION

Command line access to Putty.
Written by Simon Brown (2013).

#>

Function Connect-Putty {
[CmdletBinding(SupportsShouldProcess=$true)]
Param (
[Parameter(Mandatory=$true,ValueFromPipeline=$false,Position=1)]#[ValidateSet("ssh","telnet","rlogin","raw")]
[string]$Protocol,
[Parameter(Mandatory=$true,ValueFromPipeline=$true,Position=2)][string]$Destination
)

#$Putty = E:\Utilities\putty.exe
$Protocol = "-" + $Protocol.ToLower()

Set-Location E:\Utilities
. .\"putty.exe $Protocol $Destination"

}