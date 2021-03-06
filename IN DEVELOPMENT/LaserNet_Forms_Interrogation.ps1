

Get-VM | Foreach-Object {
	$Report = "" | Select-Object -Property Name,LastPoweredOnDate
	$Report.Name = $_.Name
	$Report.LastPoweredOnDate = (Get-VIEvent -Entity $_ | Where-Object {$_.gettype().Name -eq "VmPoweredOnEvent"} | Select-Object -First 1).CreatedTime
	$Report
}

#  REPORT ON VARIOUS SETTINGS FOR ALL FORMS

Get-ChildItem *.form | Foreach-Object {
	$Report = "" | Select-Object -Property FormName,SheetName,PaperSize,PageWidth,PageHeight,Orientation
	$formName = $_.Name.TrimEnd(".form")
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | Foreach-Object {
		$Report.FormName = $formName
		$Report.SheetName = $_.Name
		$Report.PaperSize = $_.FormName
		$Report.PageWidth = ($_.PageWidth/10).ToString() + "m"
		$Report.PageHeight = ($_.PageHeight/10).ToString() + "m"
		IF ($_.Landscape -eq 0)
		{
			$Report.Orientation = "Portrait"
		}
		ELSEIF ($_.Landscape -eq 1)
		{
			$Report.Orientation = "Landscape"
		}
		$Report
	}
}



Get-ChildItem *.form | Foreach-Object {
	$Report = "" | Select-Object -Property FormName,SheetName,ReferencePrinter
	$formName = $_.Name.TrimEnd(".form")
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | Foreach-Object {
		$Report.FormName = $formName
		$Report.SheetName = $_.Name
		$Report.ReferencePrinter = $_.ReferencePrinter
		$Report
	}
}

ls | foreach {
	$Report = "" | Select -Property FolderTestID,SampleDataTestID
	$Report.FolderTestID = $_.FullName.Split("\")[6]
	$Report.SampleDataTestID = (GC (LS $_ -Recurse | Where {$_.Name -like "0*.txt"}).FullName)[1].SubString(0,4)
	$Report
}

$source = Get-Item 'c:\LaserNet Testing\6.7.0\Full Testing\Resources\LOAD\0101\Sample\Statment_backup.txt'
Get-ChildItem "0*" | Foreach {
	$testID = $_.FullName.Split("\")[-1]
	Copy-Item $source -Destination ($_.FullName + "\Sample\" + $testID + ".txt")
}

#  TRIM WHITESPACE FROM *ALL* REARRANGES IN *ALL* FORMS.

Get-ChildItem *.form | ForEach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.ChildNodes.Rearranges.RearrangeInput | ForEach-Object {
			IF ($_.TrimSpaceBefore)
				{$_.TrimSpaceBefore = "1"}
			IF ($_.TrimSpaceAfter)
				{$_.TrimSpaceAfter = "1"}
		}
		$_.ChildNodes.Patterns.Pattern.Rearranges.RearrangeInput | ForEach-Object {
			IF ($_.TrimSpaceBefore)
				{$_.TrimSpaceBefore = "1"}
			IF ($_.TrimSpaceAfter)
				{$_.TrimSpaceAfter = "1"}
		}
	}
	$xml.Save($outFile)
}

#  MOVE *ALL* REARRANGES IN *ALL* FORMS 2 UNITS TO THE LEFT.

Get-ChildItem 'LoadChecklist.form' | ForEach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.ChildNodes.Rearranges.RearrangeInput | ForEach-Object {
			IF ($_.TextInputRearrange.Left -and ($_.TextInputRearrange.Left -ne 0))
			{
				$curValue = $_.TextInputRearrange.Left
				$_.TextInputRearrange.Left = ($curValue - 2).ToString()
			}
		}
		$_.ChildNodes.Patterns.Pattern.Rearranges.RearrangeInput | ForEach-Object {
			IF ($_.TextInputRearrange.Left -and ($_.TextInputRearrange.Left -ne 0))
			{
				$curValue = $_.TextInputRearrange.Left
				$_.TextInputRearrange.Left = ($curValue - 2).ToString()
			}
		}
	}
	$xml.Save($outFile)
}

#  CHANGE *ALL* OUTPUT DESTINATIONS

Get-ChildItem *.form | ForEach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.ChildNodes | ForEach-Object {
			$_.Target | Foreach-Object {
				IF ($_.Destination)
				{$_.Destination = "Ricoh MP4501 Output Port"}
			}
		}
	}
	$xml.Save($outFile)
}
}

#  LIST *ALL* OUTPUT DESTINATIONS

Get-ChildItem *.form | ForEach-Object {
	$outFile = $_.FullName
	$Report = "" | Select-Object Destination,SheetName,FormName
	$Report.FormName = $_.BaseName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$Report.SheetName = $_.Name
		$_.ChildNodes | ForEach-Object {
			$_.Target | Foreach-Object {
				IF ($_.Destination)
				{
					$Report.Destination = $_.Destination
					$Report
				}
			}
		}
	}
}

#  DEACTIVATE MODIFIERS - CUSTOMISED FOR T QUALITY'S PRINTER MODIFIERS.

Get-ChildItem *.form | Foreach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$_.Name -eq "[script]"} | ForEach-Object {
				IF (($_.Script -like "setEfaxDNF()*") -or ($_.Script -like "setGRNPrinter()*") -or ($_.Script -like "setPDFGRN()*") -or ($_.Script -like "setIDTPOPrinter()*") -or
				($_.Script -like "setIDTReqPrinter()*") -or ($_.Script -like "setIDTTrfPrinter()*") -or ($_.Script -like "NoDelCopy()*") -or ($_.Script -like "NoEmailAddress()*") -or
				($_.Script -like "NoFaxNumber()*") -or ($_.Script -like "setArchivePrinter()*") -or ($_.Script -like "setFaxOutput()*") -or ($_.Script -like "setPOPrinter()*") -or
				($_.Script -like "setOutputPrinter()*") -or ($_.Script -like "setInvoicePrinter()*") -or ($_.Script -like "setLoadPrinter()*") -or ($_.Script -like "setDNotePrinter()*") -or
				($_.Script -like "setBLemail()*") -or ($_.Script -like "setTQInvEmail()*") -or ($_.Script -like "setInvEmailAdd()*") -or ($_.Script -like "setGenPrint()*") -or
				($_.Script -like "setGenPrint2()*") -or ($_.Script -like "setTradeCounterPrinter()*") -or ($_.Script -like "setTradeCounterLSheet()*"))
				{$_.Active = "0"}
			}
		}
	}
	$xml.Save($outFile)
}

#  LIST SCRIPT MODIFIERS.

Get-ChildItem *.form | Foreach-Object {
	$outFile = $_.FullName
	$Report = "" | Select-Object Script,FormName
	$Report.FormName = $_.BaseName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$_.Name -eq "[script]"} | ForEach-Object {
				$Report.Script = $_.Script
				$Report
			}
		}
	}
}

Get-ChildItem *.form | Foreach-Object {
	$outFile = $_.FullName
	$Report = "" | Select-Object Sheet,FormName
	$Report.FormName = $_.BaseName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$Report.Sheet = $_.Name
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$_.Name -eq "Set Duplex = Long Edge" -and $_.Active -eq "1"} | ForEach-Object {
				$Report
			}
		}
	}
}

Get-ChildItem *.form | Foreach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$_.Name -eq "Set Duplex = Long Edge"} | ForEach-Object {
				$_#.Active = "0"
			}
		}
	}
	$xml.Save($outFile)
}

Get-ChildItem *.form | Foreach-Object {
	$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$_.Script -eq "AX_addOverlays2FirstPagePrint()"}
		}
	}
} | FT

#  LIST DATABASE MODIFIERS

$buildLocation = #BUILD LOCATION#
Set-Location $buildLocation
$modNames = @()
[xml]$lnConfig = Get-Content .\LaserNet.lnconfig
$lnConfig.Settings.ObjectGUIDs.Item | Where {$_.Path."#text" -eq "DatabaseCommands"} | ForEach-Object {
	$dbComsName = $_.Name."#text"
	$dbComsGUID = $_.GUID."#text"
	Get-ChildItem .\Modifiers\*.settings | ForEach-Object {
		$modName = $_.Name.TrimEnd($_.Extension)
		[xml]$modifier = (Get-Content $_)
		IF ($modifier.settings.Command."#text" -eq $dbComsGUID)
			{
				$modNames += $modName
			}
	}
}
Get-ChildItem .\Forms\*.form | Foreach-Object {
	$outFile = $_.FullName
	$Report = "" | Select-Object ModifierName,FormName
	$Report.FormName = $_.BaseName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$_.Modifiers.Modifier | ForEach-Object {
			$_.Modifier | Where {$modNames -contains $_.Name} | ForEach-Object {
				$Report.ModifierName = $_.Name
				$Report
			}
		}
	}
}



#  LIST ALL OVERLAYS

Get-ChildItem *.form | Foreach-Object {
	$report = "" | Select FormName,SheetName,Page,Overlay
	$report.FormName = $_.BaseName
	#$outFile = $_.FullName
	[xml]$xml = (Get-Content $_)
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$report.SheetName = $_.Name
		$Report.Page = "First"
		$_.FirstPage.Overlays.Overlay | Foreach {
			$report.Overlay = $_.FileName
			$report
		}
		$Report.Page = "Middle"
		$_.MiddlePage.Overlays.Overlay | Foreach {
			$report.Overlay = $_.FileName
			$report
		}
		$Report.Page = "Last"
		$_.LastPage.Overlays.Overlay | Foreach {
			$report.Overlay = $_.FileName
			$report
		}
		$Report.Page = "Single"
		$_.SinglePage.Overlays.Overlay | Foreach {
			$report.Overlay = $_.FileName
			$report
		}
	}
	#$xml.Save($outFile)
} | FT