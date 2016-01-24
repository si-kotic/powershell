﻿$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())

if (!($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )))
    {
        (get-host).UI.RawUI.Backgroundcolor="DarkRed"
        clear-host
        write-host "WARNING: POWERSHELL IS NOT RUNNING AS AN ELEVATED SESSION!"
    }
else
{
	function prompt{
		"ADMIN " + $(Get-Location) + ">"
	}
}

Import-Module -Name EFSTechnology
New-PSDrive -Name I -PSProvider FileSystem -Root \\nas1\it\
New-PSDrive -Name P -PSProvider FileSystem -Root \\nas1\projects\
New-PSDrive -Name R -PSProvider FileSystem -Root \\nas1\development\releases\
New-PSDrive -Name S -PSProvider FileSystem -Root \\nas1\support\
New-PSDrive -Name U -PSProvider FileSystem -Root \\nas1\users\