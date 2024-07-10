$param = @{
	Name = 'OldPassword'
	Check = {
		param ($ADObject, $Config)
		if ($ADObject.PwdLastSet -and $ADObject.PwdLastSet -lt (Get-Date).AddDays(-1 * $Config.PasswordThreshold).ToFileTime()) {
			New-AhsFinding -Check OldPassword -Threshold (Get-Date).AddDays(-1 * $Config.PasswordThreshold) -Value ([datetime]::FromFileTimeUtc($ADObject.PwdlastSet)) -ADObject $ADObject
		}
	}
	LdapFilter = {
		param ($Config)
		"(pwdLastSet<=$((Get-Date).AddDays(-1 * $Config.PasswordThreshold).ToFileTime()))"
	}
	ObjectClass = 'Person'
	Properties = 'PwdLastSet'
	Description = 'Scans for users whose password has not been set within the required time.'
	Parameters = @{
		PasswordThreshold = 180
	}
}

Register-AhsCheck @param