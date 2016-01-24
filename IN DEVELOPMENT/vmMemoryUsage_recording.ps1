

$msgBody = 'Please find below the summary of the virtual machine memory usage:'
$head = @'
<style>
  .underfifty {
    background: #F5D0A6;
  }
  .undertwentyfive {
    background: #F08484;
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


$table = New-Object system.Data.DataTable “vmPerformance”

$col1 = New-Object system.Data.DataColumn vmName,([string])
$col2 = New-Object system.Data.DataColumn memoryAllocation,([string])
$col3 = New-Object system.Data.DataColumn memoryUsage,([string])
$col4 = New-Object system.Data.DataColumn memoryUsagePercent,([string])
$col5 = New-Object system.Data.DataColumn memoryFree,([string])
$col6 = New-Object system.Data.DataColumn diskUsage,([string])
$col7 = New-Object system.Data.DataColumn cpuUsageMhz,([string])
$col8 = New-Object system.Data.DataColumn cpuUsage,([string])
$col9 = New-Object system.Data.DataColumn cpuTotalMhz,([string])
$col10 = New-Object system.Data.DataColumn cpuFreeMhz,([string])
$col11 = New-Object system.Data.DataColumn time,([string])

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

Get-VM | where {$_.PowerState -eq "PoweredOn"} | Foreach-Object {
      $row = $table.NewRow()
      $row.vmName = $_.Name
      $row.memoryAllocation = $_.MemoryMB
      $memoryUsage = (Get-Stat -Entity $_ -Stat mem.usage.average | Sort-Object Value)[-1].Value
      $row.memoryUsage = "{0:N2}" -f ($memoryUsage/100 * $_.MemoryMB)
      $row.memoryUsagePercent = $memoryUsage.ToString() + "%"
      $row.memoryDiff = "{0:N2}" -f ($_.MemoryMB - ($memoryUsage/100 * $_.MemoryMB))
	  $row.diskUsage = Get-Stat -Entity $_.
      $table.rows.add($row)
      
}


$html = ""
$html += $table | Select-Object vmName,memoryAllocation,memoryUsage,memoryUsagePercent,memoryDiff | ConvertTo-Html -Fragment | Foreach-Object {
    IF ($_.StartsWith("<tr><td>"))
      {
            IF ($_.Remove($_.length-10,10).Remove(0,8).Replace("</td><td>","*").Split("*")[3].Replace("%","") -lt 25)
        {
              $_.Replace("<tr>","<tr class='undertwentyfive'>")
        }
        ELSEIF ($_.Remove($_.length-10,10).Remove(0,8).Replace("</td><td>","*").Split("*")[3].Replace("%","") -lt 75)
        {
              $_.Replace("<tr>","<tr class='underfifty'>")
        }
        ELSE
        {$_}
      }
    ELSE
    {$_}
}
$html += "<br>"



ConvertTo-Html -InputObject $null -Head $head -Title "VM Memory Usage Summary" -PreContent ("<H4>" + $msgBody + "</H4>") -PostContent $html | Out-File 'C:\temp\Virtual Machine Management\vmMemoryUsageSummary.html'




