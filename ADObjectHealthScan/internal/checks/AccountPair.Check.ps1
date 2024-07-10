$param = @{
	Name = 'AccountPair'
	Check = {
		param ($ADObject, $Config, $ADParam)

		$newADParam = $ADParam | ConvertTo-PSFHashtable -Include Server, Credential
		foreach ($pair in $Config.Pairs) {
			if ($ADObject.SamAccountName -notmatch $pair.Pattern) { continue }

			$pairName = & ([PSFScriptblock]::new($pair.Pair, $true)).ToGlobal() $ADObject.SamAccountName
			$filter = '(samAccountName={0})' -f $pairName
			if (Get-LdapObject @newADParam -LdapFilter $filter) { continue }

			New-AhsFinding -Check AccountPair -Threshold $pairName -Value $null -ADObject $ADObject
		}
	}
	LdapFilter = {
		param ($Config)
		$filters = foreach ($item in $Config.Pairs) {
			if ($item.LdapFilter) { '(samAccountName={0})' -f $item.LdapFilter }
		}
		if (@($filters).Count -lt 1) { return '(SamAccountName=<null>)' } # Something that is (hopefully) never true
		
		'(|{0})' -f ($filters -join '')
	}
	ObjectClass = 'Person'
	Properties = 'SamAccountName'
	Description = 'Ensures a matching accounts exists. Use to catch accounts that should have a matching pair but don''t.'
	Parameters = @{
		# Expects entries of @{ LdapFilter = 'adm*'; Pattern = '^adm'; Pair = { $args[0] -replace '^adm' }}
		Pairs = @()
	}
}

Register-AhsCheck @param