# This is where the strings go, that are written by
# Write-PSFMessage, Stop-PSFFunction or the PSFramework validation scriptblocks
@{
	'Export-AhsHealthReport.Error.ImportExcelNotFound' = 'The module "ImportExcel" was not found, but is required for generating the export file! Use "Install-Module ImportExcel" to resolve this!' #
	'Export-AhsHealthReport.Error.NotAFinding' = 'The provided object is not a finding from one of the checks: {0}' # $item

	'Invoke-AhsCheck.Error.CheckFailed' = 'Check {0} failed against {1}' # $check.Name, $adObject.DistinguishedName
	'Invoke-AhsCheck.Error.CheckNotFound' = 'Cannot find check: "{0}"' # $checkname
	'Invoke-AhsCheck.Query.Send' = 'Executing LDAP query for {0}: {1}' # $checksGroup.Name, $ldapFilter
}