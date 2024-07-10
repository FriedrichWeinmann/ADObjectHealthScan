$param = @{
	Name        = 'NeverLoggedIn'
	Check       = {
		param ($ADObject, $Config)
		if ($ADObject.lastLogonTimestamp) { return }
		if ($ADObject.userAccountControl -band 2048) { return } # Trust Account
		if ($ADObject.whenCreated -ge (Get-Date).AddDays(-1 * $Config.CreationGrace)) { return } # Was recently created
		if ($ADObject.SamAccountName -eq 'krbtgt') { return } # krbtgt does not log in

		New-AhsFinding -Check NeverLoggedIn -Threshold $false -Value $true -ADObject $ADObject
	}
	LdapFilter  = {
		param ($Config)
		"(&(!(lastLogonTimestamp=*))(whenCreated<=$((Get-Date).AddDays(-1 * $Config.CreationGrace).ToString('yyyyMMddHHmmss.fZ'))))" <# Will possibly also find really new accounts if not filtering for creation date #>
	}
	ObjectClass = 'Person'
	Properties  = 'lastLogonTimestamp', 'whenCreated'
	Description = 'Scans for users who have never logged in.'
	Parameters  = @{
		CreationGrace = 30
	}
}

Register-AhsCheck @param