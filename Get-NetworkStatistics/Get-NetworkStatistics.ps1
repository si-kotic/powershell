<#

.SYNOPSIS

A replcement tool for Netstat.

This tool allows you to query network connections, routing tables and

interface and protocol statistics.

Written by Simon Brown (2012).

.DESCRIPTION

Use the tool to find the same information that you would Netstat however

this tool gives you the ability to filter that information in a much

more user friendly manner as well as return specific values and pipe them

to other commands.

It is also possible to output the results to a CSV or XML file using the

standard Export-Csv and Export-Clixml Cmdlets.

.EXAMPLE

Get-NetworkStatistics | Ft

Protocol       LocalAddress   LocalPort      RemoteAddress  RemotePort     State          ProcessName    PID
--------       ------------   ---------      -------------  ----------     -----          -----------    ---
TCP            0.0.0.0        80             0.0.0.0        0              LISTENING      System         4
TCP            0.0.0.0        135            0.0.0.0        0              LISTENING      svchost        972
TCP            0.0.0.0        445            0.0.0.0        0              LISTENING      System         4
TCP            0.0.0.0        515            0.0.0.0        0              LISTENING      svchost        11212


.EXAMPLE

Get-NetworkStatistics | Where {$_.LocalPort -eq "8100"}

Protocol       LocalAddress   LocalPort      RemoteAddress  RemotePort     State          ProcessName    PID
--------       ------------   ---------      -------------  ----------     -----          -----------    ---
TCP            0.0.0.0        8100           0.0.0.0        0              LISTENING      java           8544


.EXAMPLE

Get-NetworkStatistics | Where {$_.LocalPort -eq "8100"} | Export-Csv c:\temp\output.csv

NB.  When exporting to file, no output is returned in the console.


#>
function Get-NetworkStatistics 
{ 
    $properties = 'Protocol','LocalAddress','LocalPort' 
    $properties += 'RemoteAddress','RemotePort','State','ProcessName','PID' 

    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object { 

        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) 

        if($item[1] -notmatch '^\[::') 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split('\]:')[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(':')[0] 
                $localPort = $item[1].split(':')[-1] 
            }  

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split('\]:')[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(':')[0] 
               $remotePort = $item[2].split(':')[-1] 
            }  

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
}