
#	LaserNet Licensing
Function LaserNet-License {
Param (
[string]$lasernetLicense
)


#	READ LICENSE FILE AS XML
$licenseFile = Get-Item $lasernetLicense 
$license = [XML](Get-Content $licenseFile.FullName)

#	CREATE TABLE
$table = New-Object system.Data.DataTable “LaserNet License”

$col1 = New-Object system.Data.DataColumn createdBy,([string])
$col2 = New-Object system.Data.DataColumn version,([string])
$col3 = New-Object system.Data.DataColumn createdOn,([string])
$col4 = New-Object system.Data.DataColumn customerID,([string])
$col5 = New-Object system.Data.DataColumn customerName,([string])
$col6 = New-Object system.Data.DataColumn comments,([string])
$col7 = New-Object system.Data.DataColumn Developer,([string])
$col8 = New-Object system.Data.DataColumn "DOCX to PDF",([string])
$col9 = New-Object system.Data.DataColumn "Excel to Text",([string])
$col10 = New-Object system.Data.DataColumn "Excel to XML",([string])
$col11 = New-Object system.Data.DataColumn "File Details",([string])
$col12 = New-Object system.Data.DataColumn Graph,([string])
$col13 = New-Object system.Data.DataColumn "HTML to XML",([string])
$col14 = New-Object system.Data.DataColumn "JD Edwards PDF to Text",([string])
$col15 = New-Object system.Data.DataColumn "Module Development",([string])
$col16 = New-Object system.Data.DataColumn OCR,([string])
$col17 = New-Object system.Data.DataColumn "PDF Security",([string])
$col18 = New-Object system.Data.DataColumn "PDF to Text",([string])
$col19 = New-Object system.Data.DataColumn "Printer Output",([string])
$col20 = New-Object system.Data.DataColumn "SAP BC-XOM",([string])
$col21 = New-Object system.Data.DataColumn "SimplePDF to Text",([string])
$col22 = New-Object system.Data.DataColumn "Supervisor",([string])
$col23 = New-Object system.Data.DataColumn "TIFF",([string])
$col24 = New-Object system.Data.DataColumn "XML Engine",([string])
$col25 = New-Object system.Data.DataColumn "XML Validator",([string])
$col26 = New-Object system.Data.DataColumn "Mail Output",([string])
$col27 = New-Object system.Data.DataColumn "Microsoft Fax",([string])
$col28 = New-Object system.Data.DataColumn "Conversion",([string])
$col29 = New-Object system.Data.DataColumn "PDF",([string])
$col30 = New-Object system.Data.DataColumn "Database Command",([string])
$col31 = New-Object system.Data.DataColumn "SharePoint",([string])
$col32 = New-Object system.Data.DataColumn "Web Service",([string])
$col33 = New-Object system.Data.DataColumn "File Output",([string])
$col34 = New-Object system.Data.DataColumn "Base64 Filter",([string])
$col35 = New-Object system.Data.DataColumn "Binary Filter",([string])
$col36 = New-Object system.Data.DataColumn "Code Page Conversion",([string])
$col37 = New-Object system.Data.DataColumn "Compression",([string])
$col38 = New-Object system.Data.DataColumn "EDI - XML",([string])
$col39 = New-Object system.Data.DataColumn "EMF to RAW",([string])
$col40 = New-Object system.Data.DataColumn "File Database",([string])
$col41 = New-Object system.Data.DataColumn "File Input",([string])
$col42 = New-Object system.Data.DataColumn "FTP",([string])
$col43 = New-Object system.Data.DataColumn "HTTP",([string])
$col44 = New-Object system.Data.DataColumn "JobEvent",([string])
$col45 = New-Object system.Data.DataColumn "JobInfo Manipulation",([string])
$col46 = New-Object system.Data.DataColumn "JobInfo Scanner",([string])
$col47 = New-Object system.Data.DataColumn "Mail Input",([string])
$col48 = New-Object system.Data.DataColumn "MSMQ",([string])
$col49 = New-Object system.Data.DataColumn "Overlay",([string])
$col50 = New-Object system.Data.DataColumn "PBS0601",([string])
$col51 = New-Object system.Data.DataColumn "PDM Archive",([string])
$col52 = New-Object system.Data.DataColumn "Printer Input",([string])
$col53 = New-Object system.Data.DataColumn "Process",([string])
$col54 = New-Object system.Data.DataColumn "Scheduler",([string])
$col55 = New-Object system.Data.DataColumn "Script",([string])
$col56 = New-Object system.Data.DataColumn "Text Filter",([string])
$col57 = New-Object system.Data.DataColumn "Text to EMF",([string])
$col58 = New-Object system.Data.DataColumn "URL Port",([string])
$col59 = New-Object system.Data.DataColumn "Web Server",([string])
$col60 = New-Object system.Data.DataColumn "ZIP Modifier",([string])
$col61 = New-Object system.Data.DataColumn "RDI to XML",([string])
$col62 = New-Object system.Data.DataColumn "SmartXSF Modifier",([string])
$col63 = New-Object system.Data.DataColumn "Form",([string])
$col64 = New-Object system.Data.DataColumn "XML Merger",([string])
$col65 = New-Object system.Data.DataColumn "XML Splitter",([string])
$col66 = New-Object system.Data.DataColumn "XML to Text",([string])
$col67 = New-Object system.Data.DataColumn "Printer Output Printers",([string])
$col68 = New-Object system.Data.DataColumn "FTP Input",([string])
$col69 = New-Object system.Data.DataColumn "FTP Output",([string])
$col70 = New-Object system.Data.DataColumn "HTTP Input",([string])
$col71 = New-Object system.Data.DataColumn "HTTP Output",([string])
$col72 = New-Object system.Data.DataColumn "MSMQ Input",([string])
$col73 = New-Object system.Data.DataColumn "MSMQ Output",([string])
$col74 = New-Object system.Data.DataColumn "URL Port Input",([string])
$col75 = New-Object system.Data.DataColumn "URL Port Output",([string])
$col76 = New-Object system.Data.DataColumn "Form XML Input",([string])
$col77 = New-Object system.Data.DataColumn "Form XML Output",([string])
$col78 = New-Object system.Data.DataColumn "File Retriever",([string])
$col79 = New-Object system.Data.DataColumn "Pass-Through",([string])
$col80 = New-Object system.Data.DataColumn "XML Transformer",([string])
$col81 = New-Object system.Data.DataColumn "Exchange",([string])
$col82 = New-Object system.Data.DataColumn "One 2 One",([string])
$col83 = New-Object system.Data.DataColumn "Text Splitter",([string])

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
$table.columns.add($col36)
$table.columns.add($col37)
$table.columns.add($col38)
$table.columns.add($col39)
$table.columns.add($col40)
$table.columns.add($col41)
$table.columns.add($col42)
$table.columns.add($col43)
$table.columns.add($col44)
$table.columns.add($col45)
$table.columns.add($col46)
$table.columns.add($col47)
$table.columns.add($col48)
$table.columns.add($col49)
$table.columns.add($col50)
$table.columns.add($col51)
$table.columns.add($col52)
$table.columns.add($col53)
$table.columns.add($col54)
$table.columns.add($col55)
$table.columns.add($col56)
$table.columns.add($col57)
$table.columns.add($col58)
$table.columns.add($col59)
$table.columns.add($col60)
$table.columns.add($col61)
$table.columns.add($col62)
$table.columns.add($col63)
$table.columns.add($col64)
$table.columns.add($col65)
$table.columns.add($col66)
$table.columns.add($col67)
$table.columns.add($col68)
$table.columns.add($col69)
$table.columns.add($col70)
$table.columns.add($col71)
$table.columns.add($col72)
$table.columns.add($col73)
$table.columns.add($col74)
$table.columns.add($col75)
$table.columns.add($col76)
$table.columns.add($col77)
$table.columns.add($col78)
$table.columns.add($col79)
$table.columns.add($col80)
$table.columns.add($col81)
$table.columns.add($col82)
$table.columns.add($col83)



#	INTERROGATE LICENSE
$row = $table.NewRow()

$row.version = $license.LaserNetLicense.Version
$row.createdBy = $license.LaserNetLicense.CreatedBy
$createdOnDate = $license.LaserNetLicense.CreatedOn
$row.createdOn = (Get-Date -Year $createdOnDate.Substring(0,4) -Month $createdOnDate.SubString(4,2) -Day $createdOnDate.Substring(6,2) -Hour 00 -Minute 00 -Second 00).ToShortDateString()
$row.customerID = $license.LaserNetLicense.CustomerID
$row.customerName = $license.LaserNetLicense.CustomerName
$row.comments = $license.LaserNetLicense.Comment
$license.LaserNetLicense.Licenses.License | Foreach {
	$row.($_.Name) = $_.Licensed
	IF ($_.Additional)
	{
		$_.Additional | Foreach-Object {
			$row.($_.ParentNode.Name + " " + $_.Name) = $_.Value
		}
	}
}
$table.rows.add($row)

#	EMAIL SETTINGS
$msgSender = "simonb@efstechnology.com"
$msgRecipient = "simonb@efstechnology.com"
$smtpServer = "sbs002.aps-cambridge.local"
$msgSubject = 'LaserNet License for ' + $license.LaserNetLicense.CustomerName
$msgBody = 'Summary of LaserNet License for ' + $license.LaserNetLicense.CustomerName + ':'
$head = @'
<basefont color=#003399 face="Sans-Serif" />
<style>
  .licensed {
    background: #ccd7ff;
  }
  .expiry {
	color: #8b3a3a;
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

#	CREATE HTML FOR EMAIL BODY
$html = ""
$html = $table | Select-Object CustomerName,Version,"Printer Output Printers",CreatedOn | ConvertTo-Html -Fragment

#	EXPORT TO CSV
IF (!(Test-Path "C:\Temp\")) {New-Item -Name "Temp" -Path C:\ -ItemType Directory -Force}
$table | Export-Csv ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv")
$csv = Get-Content ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv")
$csv[1..$csv.Count] | Set-Content ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv")

#	EMAIL CSV AND HTML TABLES
#Send-MailMessage -To $msgRecipient -From $msgSender -SmtpServer $smtpServer -Subject $ExecutionContext.InvokeCommand.ExpandString($msgSubject) -BodyAsHTML (ConvertTo-Html -InputObject $null -Head $head -Title "LaserNet License" -PreContent ("<H4>" + $ExecutionContext.InvokeCommand.ExpandString($msgBody) + "</H4>") -PostContent $html | out-string) -Attachments ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv"),$licenseFile.FullName
Send-MailMessage -To $msgRecipient -From $msgSender -SmtpServer $smtpServer -Subject $msgSubject -BodyAsHTML (ConvertTo-Html -InputObject $null -Head $head -Title "LaserNet License" -PreContent ("<H4>" + $msgBody + "</H4>") -PostContent $html | out-string) -Attachments ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv"),$licenseFile.FullName
#Send-MailMessage -To $adminEmail -From $msgFrom -SmtpServer $smtpServer -Subject $msgSubject -Body $msgBody -Attachments C:\Temp\lasernetLicense.csv
Remove-Item -Path ("C:\Temp\lasernetLicense" + $license.LaserNetLicense.CustomerName + ".csv") -Force

}