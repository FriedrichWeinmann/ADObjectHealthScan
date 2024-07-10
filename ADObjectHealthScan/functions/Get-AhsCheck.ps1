function Get-AhsCheck {
	<#
	.SYNOPSIS
		List the available checks.
	
	.DESCRIPTION
		List the available checks.
		Checks are the tests available for scanning AD Principals for configuration health.
		Use Register-AhsCheck to provide your own custom checks.
	
	.PARAMETER Name
		Name of the check to retrieve.
		Defaults to: *
	
	.EXAMPLE
		PS C:\> Get-AhsCheck

		List all available checks.
	#>
	[CmdletBinding()]
	param (
		[PsfArgumentCompleter('ADObjectHealthScan.Check.Name')]
		[string]
		$Name = '*'
	)
	process {
		$script:ScanExtensions.Values | Where-Object Name -Like $Name
	}
}