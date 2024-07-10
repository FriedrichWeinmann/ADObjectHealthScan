function Register-AhsCheck {
	<#
	.SYNOPSIS
		Registers the logic used to validate an AD Object's health.
	
	.DESCRIPTION
		Registers the logic used to validate an AD Object's health.
		This makes the check available in subsequent validation calls.
	
	.PARAMETER Name
		Name of the check.
		Is also used during configuration and as part of the output result.
	
	.PARAMETER Check
		The checking logic, that is executed against the retrieved AD object.
		This scriptblock will receive as input:
		- The AD Object being scanned
		- The Configuration hashtable containing the settings for this check,
		In case of a finding, this scriptblock must call "New-AhsFinding" to return a finding result.
	
	.PARAMETER LdapFilter
		A scriptblock that receives the Configuration Hashtable for this check as input.
		It must then return a valid LDAP Filter string - that filter will become part of a larger LDAP Filter,
		which also already specifies the ObjectCategory, meaning this filter can skip that.

		Example:
		param ($Config)
		"(pwdLastSet<=$((Get-Date).AddDays(-1 * $Config.PasswordThreshold).ToFileTime()))"
	
	.PARAMETER ObjectClass
		The Object Class of the item this check applies to.
		Checks will only be applied to objects of that class.
	
	.PARAMETER Properties
		Which properties are needed for this check.
		All checks applied will pool their requried properties, allowing performance optimization.
	
	.PARAMETER Description
		A quick description of what this check is all about.
		Documentation only.
	
	.PARAMETER Parameters
		The parameters the check supports and the default values they have if not specified.
	
	.EXAMPLE
		PS C:\> Register-AhsCheck -Name OldPassword -Check $check -LdapFilter $filter -ObjectClass user -Properties 'PwdLastSet' -Parameters @{ Threshold = 180 }

		Registers the check "OldPassword", which applies to users, uses the property "PwdLastSet" and comes with a default threshold of 180.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfValidateScript('PSFramework.Validate.SafeName', ErrorString = 'PSFramework.Validate.SafeName')]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[scriptblock]
		$Check,

		[Parameter(Mandatory = $true)]
		[scriptblock]
		$LdapFilter,

		[Parameter(Mandatory = $true)]
		[string[]]
		$ObjectClass,

		[string[]]
		$Properties,

		[string]
		$Description,

		[hashtable]
		$Parameters
	)
	process {
		$script:ScanExtensions[$Name] = [PSCustomObject]@{
			PSTypeName  = 'ADObjectHealthScan.Check'
			Name        = $Name
			Check       = $Check
			LdapFilter  = $LdapFilter
			ObjectClass = $ObjectClass
			Properties  = $Properties
			Description = $Description
			Parameters  = $Parameters
		}
	}
}