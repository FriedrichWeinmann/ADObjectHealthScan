function New-AhsFinding {
	<#
	.SYNOPSIS
		Create a new finding result.
	
	.DESCRIPTION
		Create a new finding result.
		This command should be used only from within the code provided by a custom check.
	
	.PARAMETER Check
		Name of the check that failed.
	
	.PARAMETER Threshold
		What would have been the expected/minimum/maximum value?
	
	.PARAMETER Value
		What was the actual value found.
	
	.PARAMETER ADObject
		The AD Object that was tested.
	
	.EXAMPLE
		PS C:\> New-AhsFinding -Check NeverLoggedIn -Threshold $false -Value $true -ADObject $ADObject

		Creates a new finding for the check "NeverLoggedIn"
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Check,

		[Parameter(Mandatory = $true)]
		[AllowNull()]
		$Threshold,

		[Parameter(Mandatory = $true)]
		[AllowNull()]
		$Value,

		[Parameter(Mandatory = $true)]
		$ADObject
	)
	process {
		[PSCustomObject]@{
			PSTypeName        = 'ADObjectHealthScan.Finding'
			Check             = $Check
			SamAccountName    = $ADObject.SamAccountName
			Threshold         = $Threshold
			Value             = $Value
			DistinguishedName = $ADObject.DistinguishedName
			Enabled           = -not ($ADObject.userAccountControl -band 2)
		}
	}
}