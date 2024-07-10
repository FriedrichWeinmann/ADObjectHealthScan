$param = @{
	Name        = 'BadEncryptionTypes'
	Check       = {
		param ($ADObject, $Config)
		if (($ADObject.'msDS-SupportedEncryptionTypes' -band 7) -and -not ($ADObject.'msDS-SupportedEncryptionTypes' -band 56)) {
			New-AhsFinding -Check BadEncryptionTypes -Threshold ([EncryptionType]56) -Value ([EncryptionType]$ADObject.'msDS-SupportedEncryptionTypes') -ADObject $ADObject
		}
	}
	LdapFilter  = {
		param ($Config)
		$subSegments = @(
			'(msDS-SupportedEncryptionTypes:1.2.840.113556.1.4.804:=7)' # RC4 and worse
			'(!(msDS-SupportedEncryptionTypes:1.2.840.113556.1.4.804:=56))' # NOT Aes 128 or better
		)
		$filterSegments += ('(&{0})' -f ($subSegments -join ''))
	}
	ObjectClass = 'Person'
	Properties  = 'PwdLastSet'
	Description = 'Scans for users whose Encryption types prevent modern AES modes.'
	Parameters  = @{}
}

Register-AhsCheck @param