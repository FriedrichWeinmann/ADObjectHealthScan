function Get-AhsPrivilegedPrincipal {
	<#
	.SYNOPSIS
		Retrieves all privileged accounts in a domain.
	
	.DESCRIPTION
		Retrieves all privileged accounts in a domain.
		Includes nested group memberships and non-user principals.

		Note: This scan is ONLY scanning for membership in privileged groups.
		If you want to ensure no other escalation path exists, use a tool such as the
		Active Directory Management Framework (admf.one) to scan for unexpected delegations.

		List of privileged groups taken from the Protected Accounts and Groups:
		https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-c--protected-accounts-and-groups-in-active-directory
	
	.PARAMETER Name
		Name filter applied to the returned principals.
		Defaults to: *
	
	.PARAMETER Group
		Name of privileged group to consider for the result.
		Defaults to: *
	
	.PARAMETER ExcludeBuiltIn
		By default, the krbtgt and Administrator account are returned, irrespective of any other filtering.
		This disables that behavior.
	
	.PARAMETER IncludeGroups
		Include groups in the list of members of privileged groups.
		By default, groups that are members of a privileged groups are not returned, just its non-group members (recursively).
	
	.PARAMETER Server
		The server / domain to contact.
	
	.PARAMETER Credential
		The credentials to use with the request
	
	.EXAMPLE
		PS C:\> Get-AhsPrivilegedPrincipal

		Retrieves all privileged accounts in the current domain.

	.LINK
		https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/appendix-c--protected-accounts-and-groups-in-active-directory
	#>
	[CmdletBinding()]
	param (
		[string]
		$Name = '*',

		[string]
		$Group = '*',

		[switch]
		$ExcludeBuiltIn,

		[switch]
		$IncludeGroups,

		[string]
		$Server,

		[PSCredential]
		$Credential
	)
	begin {
		$privilegedGroupRids = @(
			'498' # Enterprise Read-only Domain Controllers
			'512' # Domain Admins
			'516' # Domain Controllers
			'518' # Schema Admins
			'519' # Enterprise Admins
			'521' # Read-only DOmain Controllers
		)
		$privilegedBuiltinGroups = @(
			'S-1-5-32-544' # Administrators
			'S-1-5-32-548' # Account Operators
			'S-1-5-32-549' # Server Operators
			'S-1-5-32-550' # Print Operators
			'S-1-5-32-551' # Backup Operators
			'S-1-5-32-552' # Replicator
		)
		$privilegedAccountRids = @(
			'500' # Administrator
			'502' # krbtgt
		)

		$adParam = @{}
		if ($Server) { $adParam.Server = $Server }
		if ($Credential) { $adParam.Credential = $Credential }
	}
	process {
		$domain = Get-LdapObject @adParam -LdapFilter '(objectCategory=domainDNS)'

		#region Builtin Privileged Accounts
		if (-not $ExcludeBuiltIn) {
			foreach ($rid in $privilegedAccountRids) {
				$user = Get-LdapObject @adParam -LdapFilter "(objectSID=$($domain.ObjectSID)-$rid)" -Property SamAccountName, ObjectClass, ObjectSID, DistinguishedName
				if ($user.Name -notlike $Name) { continue }

				[PSCustomObject]@{
					PSTypeName = 'ADObjectHealthScan.Privileged.GroupMember'
					GroupName  = 'n/a'
					GroupDN    = $null
					GroupSID   = $null
					MemberName = $user.SamAccountName
					MemberType = $user.ObjectClass
					MemberSID  = $user.ObjectSID
					MemberDN   = $user.DistinguishedName
				}
			}
		}
		#endregion Builtin Privileged Accounts
	
		#region Resolve Groups to check
		$groupsDefault = foreach ($rid in $privilegedGroupRids) {
			Get-LdapObject @adParam -LdapFilter "(objectSID=$($domain.ObjectSID)-$rid)" -Property SamAccountName, DistinguishedName, ObjectSID -ErrorAction Stop
		}
		$groupsBuiltin = foreach ($sid in $privilegedBuiltinGroups) {
			Get-LdapObject @adParam -LdapFilter "(objectSID=$sid)" -Property SamAccountName, DistinguishedName, ObjectSID -ErrorAction Stop
		}
		$relevantGroups = @($groupsDefault) + @($groupsBuiltin) | Write-Output | Where-Object { $_ -and $_.SamAccountName -like $Group }
		#endregion Resolve Groups to check

		#region Resolve privileged entities
		foreach ($relevantGroup in $relevantGroups) {
			$members = Get-LdapObject @adParam -LDAPFilter "(&(objectSID=*)(memberof:1.2.840.113556.1.4.1941:=$($relevantGroup.DistinguishedName)))" -Properties ObjectSID, SamAccountName, ObjectClass, DistinguishedName
			foreach ($member in $members) {
				if ($member.SamAccountName -notlike $Name) { continue }
				if ($member.ObjectClass -eq 'Group' -and -not $IncludeGroups) { continue }
				[PSCustomObject]@{
					PSTypeName = 'ADObjectHealthScan.Privileged.GroupMember'
					GroupName  = $relevantGroup.SamAccountName
					GroupDN    = $relevantGroup.DistinguishedName
					GroupSID   = $relevantGroup.ObjectSID
					MemberName = $member.SamAccountName
					MemberType = $member.ObjectClass
					MemberSID  = $member.ObjectSID
					MemberDN   = $member.DistinguishedName
				}
			}
		}
		#endregion Resolve privileged entitie
	}
}