function Invoke-AhsCheck {
	<#
	.SYNOPSIS
		Verify AD object health, based on the configuration provided.
	
	.DESCRIPTION
		Verify AD object health, based on the configuration provided.
		This applies the registered and configured checks against corresponding objects in AD.

		For more details on how to define checks, see the help on Register-AhsCheck.
		
		The configuration - whether provided through hashtable or config file - looks like this:

		@{
			NameOfCheck1 = @{ NameOfParameter = 42 }
			NameOfCheck2 = @{ } # Execute with default parameter settings
		}
		
		Only configured checks will be executed, even if explicitly specifying the "-IncludeCheck" parameter.
		To apply _all_ checks no matter what, specify the "_All" option:

		@{
			_All = $true # Execute all checks, including those no configuration is provided for
			NameOfCheck1 = @{ NameOfParameter = 42 }
			NameOfCheck2 = @{ SomeThreshold = 128 }
		}

		By default, all object classes that apply to a check are used.
		To limit that, also provide the "_ObjectClasses" option:

		@{
			_All = $true # Execute all checks, including those no configuration is provided for
			_ObjectClasses = 'Person', 'Group' # Only execute checks against persons and groups.
			NameOfCheck1 = @{ NameOfParameter = 42 }
			NameOfCheck2 = @{ SomeThreshold = 128 }
		}
	
	.PARAMETER Configuration
		A configuration hashtable, defining how the scan should be performed.
		See the Description for notes on how this should be defined.
	
	.PARAMETER ConfigFile
		Path to a configuration file to read.
		See the Description for notes on how this should be defined.
	
	.PARAMETER All
		Rather than loading a specific config file, execute al available checks with the default configuration.
	
	.PARAMETER IncludeCheck
		Only execute these checks.
	
	.PARAMETER ExcludeCheck
		Do not execute these checks.
	
	.PARAMETER IncludeClass
		Only execute checks against these object classes.
	
	.PARAMETER ExcludeClass
		Do not execute checks against these object classes.
	
	.PARAMETER SearchRoot
		Only scan objects under this OU.
	
	.PARAMETER Server
		The server/domain to connect to for the scan.
	
	.PARAMETER Credential
		The credentials to use for scanning.
	
	.PARAMETER EnableException
		This parameters disables user-friendly warnings and enables the throwing of exceptions.
		This is less user friendly, but allows catching exceptions in calling scripts.
	
	.EXAMPLE
		PS C:\> Invoke-AhsCheck -ConfigFile C:\Scripts\adobjecthealth.config.psd1
		
		Executes the configuration defined / provided.
	#>
	[CmdletBinding(DefaultParameterSetName = 'Config')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'Config')]
		[hashtable]
		$Configuration,

		[Parameter(Mandatory = $true, ParameterSetName = 'File')]
		[PSFFile]
		$ConfigFile,

		[Parameter(Mandatory = $true, ParameterSetName = 'All')]
		[switch]
		$All,

		[PsfArgumentCompleter('ADObjectHealthScan.Check.Name')]
		[string[]]
		$IncludeCheck,

		[PsfArgumentCompleter('ADObjectHealthScan.Check.Name')]
		[string[]]
		$ExcludeCheck,

		[PsfArgumentCompleter('ADObjectHealthScan.Check.Class')]
		[string[]]
		$IncludeClass,

		[PsfArgumentCompleter('ADObjectHealthScan.Check.Class')]
		[string[]]
		$ExcludeClass,

		[string]
		$SearchRoot,

		[string]
		$Server,

		[PSCredential]
		$Credential,

		[switch]
		$EnableException
	)
	begin {
		$adParam = $PSBoundParameters | ConvertTo-PSFHashtable -Include Server, Credential, SearchRoot
		$config = $Configuration
		if ($ConfigFile) { $config = Import-PSFPowerShellDataFile -LiteralPath $ConfigFile | Microsoft.PowerShell.Utility\Select-Object -First 1 }
		if ($All) { $config = @{ _All = $true } }

		if (-not $config) { $config = @{} }

		$allClasses = (Get-AhsCheck).ObjectClass | Sort-Object -Unique
		if (-not $config._ObjectClasses) { $config._ObjectClasses = $allClasses }
		if ($IncludeClass) { $config._ObjectClasses = $config._ObjectClasses | Where-Object { $_ -in $IncludeClass } }
		if ($ExcludeClass) { $config._ObjectClasses = $config._ObjectClasses | Where-Object { $_ -notin $ExcludeClass } }

		if (-not $SearchRoot -and $config._SearchRoot) {
			$adParam.SearchRoot = $config._SearchRoot
		}
	}
	process {
		# Resolve Checks
		if ($config._All) { $checks = $script:ScanExtensions.Values }
		else {
			$checks = foreach ($checkName in $config.Keys) {
				if ($checkName -match '^_') { continue }
				if (-not $script:ScanExtensions[$checkName]) {
					Write-PSFMessage -Level Warning -String 'Invoke-AhsCheck.Error.CheckNotFound' -StringValues $checkName
					continue
				}
	
				$script:ScanExtensions[$checkName]
			}
		}
		$checks = $checks | Where-Object {
			(-not $IncludeCheck -or $_.Name -in $IncludeCheck) -and
			(-not $ExcludeCheck -or $_.Name -notin $ExcludeCheck)
		}

		# Resolve Check Configuration
		$effectiveConfig = @{ }
		foreach ($check in $checks) {
			$effectiveConfig[$check.Name] = $check.Parameters.Clone()
			foreach ($parameter in $config.$($check.Name).Keys) {
				$effectiveConfig[$check.Name][$parameter] = $config.$($check.Name).$parameter
			}
		}

		#region Perform all Scanning
		$objectClasses = $checks.ObjectClass | Sort-Object -Unique | Where-Object { $_ -in $config._ObjectClasses }
		foreach ($objectClass in $objectClasses) {
			$classChecks = $checks | Where-Object ObjectClass -Contains $objectClass
			# Calculate LDAP Filter
			$filterSegments = foreach ($check in $classChecks) {
				& $check.LdapFilter $effectiveConfig[$check.Name]
			}
			$ldapFilter = '(&(objectCategory={0})(|{1}))' -f $objectClass, ($filterSegments -join '')

			# Calculate Properties
			$properties = @('samAccountName', 'distinguishedName', 'userAccountControl') + $($classChecks.Properties) | Remove-PSFNull | Sort-Object -Unique

			# Collect Objects
			Write-PSFMessage -String 'Invoke-AhsCheck.Query.Send' -StringValues $objectClass, $ldapFilter
			$adObjects = Get-LdapObject @adParam -LdapFilter $ldapFilter -Property $properties

			# For Each object, generate findings
			foreach ($adObject in $adObjects) {
				foreach ($check in $classChecks) {
					try { & $check.Check $adObject $effectiveConfig[$check.Name] $adParam }
					catch { Write-PSFMessage -Level Error -String 'Invoke-AhsCheck.Error.CheckFailed' -StringValues $check.Name, $adObject.DistinguishedName -ErrorRecord $_ -PSCmdlet $PSCmdlet -EnableException $EnableException.ToBool() }
				}
			}
		}
		#endregion Perform all Scanning
	}
}