$param = @{
	Name = 'PasswordChangeRequired'
	Check = {
		param ($ADObject, $Config)
		if ($ADObject.PwdLastSet -gt 0) { return } # Setting the flag for must change password is implemented by resetting the PwdLastSet flag
		if ($ADObject.LastLogonTimestamp -lt 1) { return } # Never logged in is handled separately
		
		New-AhsFinding -Check PasswordChangeRequired -Threshold $false -Value $true -ADObject $ADObject
	}
	LdapFilter = {
		param ($Config)
		'(&(PwdLastSet=0)(LastLogonTimestamp>=1))'
	}
	ObjectClass = 'Person'
	Properties = 'PwdLastSet', 'LastLogonTimestamp'
	Description = 'Scans for users who must change their password on next logon.'
	Parameters = @{}
}

Register-AhsCheck @param