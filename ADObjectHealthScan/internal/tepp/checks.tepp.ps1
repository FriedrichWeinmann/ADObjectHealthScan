Register-PSFTeppScriptblock -Name 'ADObjectHealthScan.Check.Name' -ScriptBlock {
	(Get-AhsCheck).Name | Sort-Object
} -Global

Register-PSFTeppScriptblock -Name 'ADObjectHealthScan.Check.Class' -ScriptBlock {
	(Get-AhsCheck).ObjectClass | Sort-Object -Unique
} -Global