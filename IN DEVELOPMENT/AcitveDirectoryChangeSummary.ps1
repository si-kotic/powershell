<#

.SUMMARY

Active Directory Changes Report
Written by Simon Brown (2013)

#>

#SMTP settings
$smtpServer = "sbs002"
$msgPort = 25
$msgFrom = "simonb@efstechnology.com"

#Reporting email address
$adminEmail = "simonb@efstechnology.com"

#Email
$msgSubject = 'Active Directory Change Report'
$msgBody = 'Please find below the summary of the changes made in Active Directory in the last 24 hours:'
$head = @'
<basefont color=#003399 face="Sans-Serif" />
<style>
  .enabled {
    background: #ccd7ff;
  }
  .vmtools {
      color: #8b3a3a;
  }
body {
      font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
        font-size: 16px;
        font-weight: bold;
        background: #fff;
        color: #039
}
table {
      font-family: "Lucida Sans Unicode", "Lucida Grande", Sans-Serif;
      font-size: 12px;
      background: #fff;
      margin: 45px;
      width: 100%;
      border-collapse: collapse;
      text-align: left;
      color: #669;
}
table th {
      font-size: 14px;
      font-weight: normal;
      color: #039;
      padding: 10px 8px;
      border-bottom: 2px solid #6678b1;
}
table td {
      padding: 9px 8px 0px 8px;
        font-weight: normal;
}
table tbody tr:hover td
{
      color: #009;
}
table tbody .vmtools:hover td
{
      color: #d00;
}
</style>
'@


$html = ""
$html += "<H5>Users who have not logged in for a month:</H5>"
$html += Get-ADUser -filter * -Properties * | Select-Object Name,LastLogonDate,Enabled | where {$_.LastLogonDate -lt (get-date 10/04/2013)} | ConvertTo-Html -Fragment | Foreach-Object {
    IF ($_.Contains("True"))
    {
        $_.Replace("<tr>","<tr class='enabled'>")
    }
    ELSE
    {
            $_
    }
}


$html += "<H5>Users created or modified in the last 24 hours:</H5>"
$html += Get-ADUser -Filter * -Properties * | Select-Object Name,SamAccountName,Created,Modified | where {($_.Created -gt ((Get-Date).AddDays(-1))) -or ($_.Modified -gt ((Get-Date).AddDays(-1)))} | ConvertTo-Html -Fragment

$html += "<H5>Objects deleted in the last 24 hours:</H5>"
$html += Get-ADObject -Filter * -IncludeDeletedObjects -Properties * | where {($_.deleted -eq $true) -and -($_.Modified -gt (Get-Date).AddDays(-1))} | Select-Object Name,ObjectClass,LastKnownParent,Created,Modified | ConvertTo-Html -Fragment

ConvertTo-Html -InputObject $null -Head $head -Title "Active Directory Change Report" -PreContent ("<H4>" + $msgBody + "</H4>") -PostContent $html | Out-File 'C:\temp\Virtual Machine Management\activeDirectoryChangeReport.html'




