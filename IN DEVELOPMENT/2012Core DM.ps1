# Installing DM on Server 2012 R2 Core

# Set PC Name and Join Domain
Rename-Computer -NewName SB2012CORE
Add-Computer -DomainName aps-cambridge.local -Credential (Get-Credential)

# Install Java
& .\jre-8u40-windows-x64.exe /s

# Install .NET
Import-Module ServerManager
Add-WindowsFeature NET-Framework-Core
Remove-Module ServerManager

# Install SQL Server
& .\en_sql_server_2014_standard_edition_x64_dvd_3932034.iso /ACTION="Install" /IACCEPTSQLSERVERLICENSETERMS /ENU /UpdateEnabled /CONFIGURATIONFILE="" /FEATURES=SQL,Tools /INDICATEPROGRESS /INSTANCENAME="SQLServer" /Q /

# This next command must be run as a user with access to TeamCity
Invoke-WebRequest "http://teamcity/repository/download/bt134/8934:id/AUTOFORM-DM_Installer-v7.2.19.jar" -OutFile "AUTOFORM-DM_Installer-v7.2.19.jar"

Invoke-WebRequest "http://artifactory/libs-releases-local/com/efstech/pdm/installer/7.2.19/installer-7.2.19-standard.jar" -OutFile "installer-7.2.19-standard.jar"
