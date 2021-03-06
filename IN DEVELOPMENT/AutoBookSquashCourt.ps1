#Specify instance variables
$username = 'simon.brown'
$password = 'OohWhatALovelyTeaParty'

#Login into FP KB
$webPage = Invoke-WebRequest -uri "http://www.melbourn-squash.co.uk/bookings/" -SessionVariable webSession
$form = $webPage.Forms[1]
$form.Fields["loginForm[login]"] = $username
$form.Fields["loginForm[password]"] = $password
Invoke-WebRequest -uri "http://kb.lasernet.formpipe.com/login" -WebSession $WebSession -Body $form.Fields -Method Post

#Download licence
Invoke-WebRequest -uri "http://kb.lasernet.formpipe.com/getAttach/105/AA-00314/Lasernet.license" -WebSession $websession -OutFile C:\scripts\Lasernet.license

#Check file and exiting if licence isn't correct
$licence = Get-Content C:\scripts\Lasernet.license

if ($licence[0] -like "*DOCTYPE html PUBLIC*")
{
    Write-Host "Incorrect licence, exiting"
    exit 
}

#Find folder name for Developer
cd "C:\ProgramData\EFS Technology\Lasernet 7\"
$foldername = gci '*-*-*-*-*'

#Check whether Developer is installed
if ($foldername -eq $null)
{
    Write-Host "Developer not found, exiting"
    exit
}

$folderpath = "C:\ProgramData\EFS Technology\Lasernet 7\" + $foldername.Name

#Copy licence for developer
Copy-Item "C:\scripts\Lasernet.license" -Destination $folderpath

#Create arguments list
$arguements = "install -n " + $instancename + " -p " + $port

#Create instance, pauses for 10 seconds
Start-Process -FilePath $LMPath -ArgumentList $arguements | Out-Null

#Checking instance was created
$service = Get-Service | Where-Object {$_.Name -match $instancename} |Select-Object Name
if ($service -eq $null)
{
    Write-Host "Instance not installed"
    exit
}

write-output "The installation of the LaserNet instance $instancename has finished"
Stop-Process -ProcessName lnlic*

#Creates folder for instance and copies licence
New-Item -ItemType directory -Path "C:\ProgramData\EFS Technology\Lasernet 7\$instancename"
Copy-Item "C:\scripts\Lasernet.license" -Destination "C:\ProgramData\EFS Technology\Lasernet 7\$instancename"