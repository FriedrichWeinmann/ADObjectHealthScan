﻿@{
	# Script module or binary module file associated with this manifest
	RootModule        = 'ADObjectHealthScan.psm1'
	
	# Version number of this module.
	ModuleVersion     = '1.0.0'
	
	# ID used to uniquely identify this module
	GUID              = '8e3ccf60-cfb6-42c5-b809-a0add3ec4e86'
	
	# Author of this module
	Author            = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName       = ' '
	
	# Copyright statement for this module
	Copyright         = 'Copyright (c) 2024 Friedrich Weinmann'
	
	# Description of the functionality provided by this module
	Description       = 'Scan Framework to analyze AD Object health'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules   = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.11.341' }
		@{ ModuleName = 'LdapTools'; ModuleVersion = '1.1.7' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	# RequiredAssemblies = @('bin\ADObjectHealthScan.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\ADObjectHealthScan.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess = @('xml\ADObjectHealthScan.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport = @(
		'Export-AhsHealthReport'
		'Get-AhsCheck'
		'Get-AhsPrivilegedPrincipal'
		'Invoke-AhsCheck'
		'New-AhsFinding'
		'Register-AhsCheck'
	)
	
	# Cmdlets to export from this module
	CmdletsToExport   = @()
	
	# Variables to export from this module
	VariablesToExport = '*'
	
	# Aliases to export from this module
	AliasesToExport   = @()
	
	# List of all modules packaged with this module
	ModuleList        = @()
	
	# List of all files packaged with this module
	FileList          = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData       = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags         = @('ActiveDirectory', 'ldap', 'health')
			
			# A URL to the license for this module.
			LicenseUri   = 'https://github.com/FriedrichWeinmann/ADObjectHealthScan/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri   = 'https://github.com/FriedrichWeinmann/ADObjectHealthScan'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/FriedrichWeinmann/ADObjectHealthScan/blob/master/ADObjectHealthScan/changelog.md'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}