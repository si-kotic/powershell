#Get-ChildItem '*.form' 

"Order Acknowledgement UK.form",
"RMA.form",
"Order Acknowledgement International.form",
"Italian Order Acknowledgement.form",
"Purchase Order.form" | ForEach-Object {Get-Item $_} | ForEach-Object {
	$outFile = $_.FullName
	$formName = $_.BaseName
	IF (Test-Path 'C:\temp\PrometheanBuild.csv')
	{
		Remove-Item C:\temp\PrometheanBuild.csv -Force
	}
	$report = "" | Select-Object "Form Name","Sheet Name","Pattern Name",Type
	[xml]$xml = (Get-Content $_ -Encoding UTF8)
	$xml.TextForm.Form.Criterias.Recognition.Criteria | ForEach-Object {
		IF ($_.CriteriaType -eq "TextCriteria")
		{
			$curValue = $_.LinePos
			$_.LinePos = ($curValue - 2).ToString()
			IF ([int]$_.LineEndPos -ne -1)
			{
				$curValue = $_.LineEndPos
				$_.LineEndPos = ($curValue - 2).ToString()
			}
		}
	}
	$xml.TextForm.Form.Criterias.LinkRecognition.Criteria | ForEach-Object {
		IF ($_.CriteriaType -eq "TextCriteria")
		{
			$curValue = $_.LinePos
			$_.LinePos = ($curValue - 2).ToString()
			IF ([int]$_.LineEndPos -ne -1)
			{
				$curValue = $_.LineEndPos
				$_.LineEndPos = ($curValue - 2).ToString()
			}
		}
	}
	$xml.TextForm.Form.Criterias.StopRecognition.Criteria | ForEach-Object {
		IF ($_.CriteriaType -eq "TextCriteria")
		{
			$curValue = $_.LinePos
			$_.LinePos = ($curValue - 2).ToString()
			IF ([int]$_.LineEndPos -ne -1)
			{
				$curValue = $_.LineEndPos
				$_.LineEndPos = ($curValue - 2).ToString()
			}
		}
	}
	$xml.TextForm.Form.Sheets.Sheet | ForEach-Object {
		$sheetName = $_.Name
		$_.ChildNodes.Rearranges.RearrangeInput | ForEach-Object {
			IF ($_.TextInputRearrange.Left -and ([int]$_.TextInputRearrange.Left -ge 2))
			{
				$curValue = $_.TextInputRearrange.Left
				$_.TextInputRearrange.Left = ($curValue - 2).ToString()
			}
			ELSEIF ($_.TextInputRearrange.Left -and ([int]$_.TextInputRearrange.Left -eq 1))
			{
				$curValue = $_.TextInputRearrange.Left
				$_.TextInputRearrange.Left = ($curValue - 1).ToString()
			}
		}
		IF ($_.Recognition.Criteria)
		{
			$_.Recognition.Criteria | ForEach-Object {
				IF (($_.CriteriaType -eq "TextCriteria") -and ([int]$_.LinePos -ge 2))
				{
					$curValue = $_.LinePos
					$_.LinePos = ($curValue - 2).ToString()
					IF ([int]$_.LineEndPos -ne -1)
					{
						$curValue = $_.LineEndPos
						$_.LineEndPos = ($curValue - 2).ToString()
					}
				}
				ELSE
				{
					$report."Form Name" = $formName
					$report."Sheet Name" = $sheetName
					$report."Pattern Name" = "N/A"
					$report.Type = "Sheet Criteria"
					$report | Export-Csv -Append -NoTypeInformation C:\temp\PrometheanBuild.csv -Force
				}
			}
		}
		$_.ChildNodes.Patterns.Pattern | ForEach-Object {
			$patternName = $_.PatternName
			$_.Rearranges.RearrangeInput | ForEach-Object {
				IF ($_.TextInputRearrange.Left -and ([int]$_.TextInputRearrange.Left -ge 2))
				{
					$curValue = $_.TextInputRearrange.Left
					$_.TextInputRearrange.Left = ($curValue - 2).ToString()
				}
				ELSEIF ($_.TextInputRearrange.Left -and ([int]$_.TextInputRearrange.Left -eq 1))
				{
					$curValue = $_.TextInputRearrange.Left
					$_.TextInputRearrange.Left = ($curValue - 1).ToString()
				}
			}
			$_.TextInputPattern.StartCriterias.TextCriteria | ForEach-Object {
				IF ($_.LinePos -and ([int]$_.LinePos -ge 2))
				{
					$curValue = $_.LinePos
					$_.LinePos = ($curValue - 2).ToString()
					IF ([int]$_.LineEndPos -ne -1)
					{
						$curValue = $_.LineEndPos
						$_.LineEndPos = ($curValue - 2).ToString()
					}
				}
				ELSEIF (([int]$_.LinePos -eq 1) -and ($_.MatchString.SubString(0,1) -eq " "))
				{
					$curValue = $_.LinePos
					$_.LinePos = ($curValue - 1).ToString()
					IF ([int]$_.LineEndPos -ne -1)
					{
						$curValue = $_.LineEndPos
						$_.LineEndPos = ($curValue - 1).ToString()
					}
					$curValue = $_.MatchString
					$_.MatchString = $curValue.Substring(1,$curValue.length - 1)
				}
				ELSEIF (([int]$_.LinePos -eq 0) -and ($_.MatchString.SubString(0,2) -eq "  "))
				{
					IF ([int]$_.LineEndPos -ne -1)
					{
						$curValue = $_.LineEndPos
						$_.LineEndPos = ($curValue - 2).ToString()
					}
					$curValue = $_.MatchString
					$_.MatchString = $curValue.SubString(2,$curValue.Length - 2)
				}
				ELSE
				{
					$report."Form Name" = $formName
					$report."Sheet Name" = $sheetName
					$report."Pattern Name" = $patternName
					$report.Type = "Pattern Criteria"
					$report | Export-Csv -Append -NoTypeInformation C:\temp\PrometheanBuild.csv -Force
				}
			}
		}
	}
	$xml.Save($outFile)
	IF (Test-Path 'C:\temp\PrometheanBuild.log')
	{
		Write-Output "Please consult C:\temp\PrometheanBuild.log for a list of Criteria which need to be manually checked!"
	}
}
