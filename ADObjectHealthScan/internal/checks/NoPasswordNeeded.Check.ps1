$param = @{
	Name = 'NoPasswordNeeded'
	Check = {
		param ($ADObject, $Config)
		if (-not ($ADObject.userAccountControl -band 32)) { return }
		if ($ADObject.userAccountControl -band 2048) { return } # Trust Account
		if ($ADObject.ObjectSID -match '-501$') { return } # Guest Account has this flag and is expected to
		
		New-AhsFinding -Check NoPasswordNeeded -Threshold $false -Value $true -ADObject $ADObject
	}
	LdapFilter = {
		param ($Config)
		'(userAccountControl:1.2.840.113556.1.4.803:=32)' <# Password not required #>
		# https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties
	}
	ObjectClass = 'Person'
	Properties = 'userAccountControl', 'ObjectSID'
	Description = 'Scans for users who are configured to not require a password.'
	Parameters = @{}
}

Register-AhsCheck @param