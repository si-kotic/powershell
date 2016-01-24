Function Tail-File {
Param (
$Path
)
$line0 = Get-Content -Path $Path -Tail 1
$line0
While ($true)
{
	$line1 = Get-Content -Path $Path -Tail 1
	IF ($line1 -ne $line0) {
		$line1
	}
	$line0 = $line1
}
}