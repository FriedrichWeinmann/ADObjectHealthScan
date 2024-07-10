$param = @{
	Name = 'LastLogon'
	Check = {
		param ($ADObject, $Config)
		if ($ADObject.lastLogonTimestamp -and ([datetime]::FromFileTimeUtc($ADObject.lastLogonTimestamp)) -lt (Get-Date).AddDays(-1 * $Config.LogonThreshold)) {
			New-AhsFinding -Check LastLogon -Threshold (Get-Date).AddDays(-1 * $Config.LogonThreshold) -Value ([datetime]::FromFileTimeUtc($ADObject.lastLogonTimestamp)) -ADObject $ADObject
		}
	}
	LdapFilter = {
		param ($Config)
		"(lastLogonTimestamp<=$((Get-Date).AddDays(-1 * $Config.LogonThreshold).ToFileTime()))" <# Precise to ~14 Days #>
	}
	ObjectClass = 'Person', 'Computer'
	Properties = 'lastLogonTimestamp'
	Description = 'Scans for users who have not logged on within a given timerange'
	Parameters = @{
		LogonThreshold = 180
	}
}

Register-AhsCheck @param