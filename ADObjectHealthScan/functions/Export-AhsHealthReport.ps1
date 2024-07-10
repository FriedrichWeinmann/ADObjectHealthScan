function Export-AhsHealthReport {
	<#
	.SYNOPSIS
		Generate a report over all object health findings.
	
	.DESCRIPTION
		Generate a report over all object health findings.

		This command also requires the powershell module "ImportExcel"
	
	.PARAMETER Path
		The path where to write the report.
		Must be an xlsx file, but need not exist already.
		Parent folder must already exist.
	
	.PARAMETER PassThru
		Return all provided scan results.
		By default, this command will not return anything and only generate its report file.

	.PARAMETER InputObject
		The scan results to generate a report with.
		Must be the output of Invoke-AhsCheck.
	
	.PARAMETER Server
		The server/domain to connect to for the scan.
	
	.PARAMETER Credential
		The credentials to use for scanning.
	
	.EXAMPLE
		PS C:\> Invoke-AhsCheck -ConfigFile .\adscan.config.psd1 | Export-AhsHealthReport -Path .\scanresult.xlsx

		Performs the configured scan and writes a report to .\scanresult.xlsx
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfValidatePattern('\.xlsx$', ErrorMessage = 'Path must be an xlsx file!')]
		[PsfNewFile]
		$Path,

		[switch]
		$PassThru,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		$InputObject,

		[string]
		$Server,

		[PSCredential]
		$Credential
	)
	begin {
		if (-not (Get-Module ImportExcel -ListAvailable)) {
			Stop-PSFFunction -String 'Export-AhsHealthReport.Error.ImportExcelNotFound' -EnableException $true -Cmdlet $PSCmdlet
		}

		$adParam = @{}
		if ($Server) { $adParam.Server = $Server }
		if ($Credential) { $adParam.Credential = $Credential }

		$results = [System.Collections.ArrayList]@()
	}
	process {
		foreach ($item in $InputObject) {
			if ($null -eq $item) { continue }
			if ($item.PSObject.TypeNames -notcontains 'ADObjectHealthScan.Finding') {
				Write-PSFMessage -Level Warning -String 'Export-AhsHealthReport.Error.NotAFinding' -StringValues $item -PSCmdlet $PSCmdlet
				continue
			}

			$null = $results.Add($item)
			if ($PassThru) { $item }
		}
	}
	end {
		#region Add Privileged Info
		$isPrivilegedData = Get-AhsPrivilegedPrincipal @adParam -IncludeGroups
		foreach ($entry in $results) {
			$privilegedEntries = $isPrivilegedData | Where-Object MemberDN -EQ $entry.DistinguishedName
			$isPrivileged = $privilegedEntries -as [bool]

			[PSFramework.Object.ObjectHost]::AddNoteProperty(
				$entry,
				@{
					IsPrivileged = $isPrivileged
					PrivilegedGroups = $privilegedEntries.GroupName -join ', '
				}
			)
		}
		#endregion Add Privileged Info

		#region Export
		$groupedResults = $results | Group-Object Check
		$summaryEntries = foreach ($checkGroup in $groupedResults) {
			[PSCustomObject]@{
				Check = $checkGroup.Name
				Total = $checkGroup.Count
				Enabled = @($checkGroup.Group).Where{ $_.Enabled }.Count
				Disabled = @($checkGroup.Group).Where{ -not $_.Enabled }.Count
				Privileged = @($checkGroup.Group).Where{ $_.IsPrivileged }.Count
			}
		}

		$summaryEntries | Export-Excel -Path "$Path" -WorksheetName Summary
		$results | Export-Excel -Path "$Path" -WorksheetName Global
		foreach ($checkGroup in $groupedResults) {
			$checkGroup.Group | Export-Excel -Path "$Path" -WorksheetName "_$($checkGroup.Name)"
		}
		#endregion Export
	}
}