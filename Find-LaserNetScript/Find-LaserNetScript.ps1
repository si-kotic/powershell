Function Find-LaserNetScript {
Param (
[string]$functionName
)
	Get-ChildItem *.ScriptFile | Foreach {
		$report = "" | Select ScriptName,LineNumber
		$result = Select-String -InputObject $_ -SimpleMatch "function $functionName"
		IF ($result)
		{
			$report.ScriptName = $result.Filename.Split(".")[0]
			$report.LineNumber = $result.LineNumber
			$report
		}
	}
}