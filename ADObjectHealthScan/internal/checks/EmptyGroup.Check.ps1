$param = @{
	Name        = 'EmptyGroup'
	Check       = {
		param ($ADObject, $Config)
		if ($ADObject.member) { return }
		if ($ADObject.AdminCount -and $Config.ExcludeAdminGroups) { return }
		if ($Config.ExcludeBuiltIn) {
			if ($ADObject.ObjectSID -match '^S-1-5-32') { return } # Builtin Groups
			if ($ADObject.ObjectSID -match '-[45]\d\d$') { return } # RID < 1000 = Default Group
			if ($ADObject.samAccountName -in 'DnsAdmins', 'DnsUpdateProxy') { return } # Builtin DNS Groups with RID > 1000
		}

		New-AhsFinding -Check EmptyGroup -Threshold 1 -Value 0 -ADObject $ADObject
	}
	LdapFilter  = {
		param ($Config)
		if ($Config.ExcludeAdminGroups) { "(!(member=*))(!(adminCount=1))" }
		else { "(!(member=*))" }
	}
	ObjectClass = 'Group'
	Properties  = 'member', 'adminCount', 'ObjectSID'
	Description = 'Scans for groups that have no members.'
	Parameters  = @{
		ExcludeAdminGroups = $true
		ExcludeBuiltIn = $true
	}
}

Register-AhsCheck @param