@{
    # Perform all Checks, always. Any not-configured check will be applied with its default settings.
    # _All        = $true

    # Perform checks only for the following object classes
    # _ObjectClasses       = 'Person', 'Group'

	# Only search objects under this OU path
	# _SearchRoot = 'OU=Tier 0,DC=contoso,DC=com'

    # Scan Configurations
    OldPassword            = @{ PasswordThreshold = 360 }
    LastLogon              = @{ LogonThreshold = 90 }
    NeverLoggedIn          = @{}
    BadEncryptionTypes     = @{}
    PasswordNeverExpires   = @{}
    EmptyGroup             = @{}
    NoPasswordNeeded       = @{}
    PasswordChangeRequired = @{}
    AccountPair            = @{
        Pairs = @(
            @{ LdapFilter = 'adm-*'; Pattern = '^adm-'; Pair = { $args[0] -replace '^adm-' } }
        )
    }
}