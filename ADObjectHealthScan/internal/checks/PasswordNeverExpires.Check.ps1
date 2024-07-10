$param = @{
	Name = 'PasswordNeverExpires'
	Check = {
		param ($ADObject, $Config)
		if (-not ($ADObject.userAccountControl -band 65536)) { return }
		
		New-AhsFinding -Check PasswordNeverExpires -Threshold $false -Value $true -ADObject $ADObject
	}
	LdapFilter = {
		param ($Config)
		'(userAccountControl:1.2.840.113556.1.4.803:=65536)' <# Password never expires #>
	}
	ObjectClass = 'Person'
	Properties = 'userAccountControl'
	Description = 'Scans for users whose password has been set to never expire.'
	Parameters = @{}
}

Register-AhsCheck @param