# AccountPair

## Description

Ensures a matching accounts exists. Use to catch accounts that should have a matching pair but don't.
This check is intended for environments, where users with administrative privileges have a dedicated admin account and you want to ensure, that each admin account has its matching regular account.

## Object Class

+ Person

## Parameters

|Name|Type|Default|Description|
|---|---|---|---|
|Pairs|Array|@()|The account pair mappings definition (see below for details)|

The `Pairs` parameter is among the more complex ones, as it is an array of Hashtables that must have the correct keys & values.
A quick example:

```powershell
@{ LdapFilter = 'adm-*'; Pattern = '^adm-'; Pair = { $args[0] -replace '^adm-' } }
```

The hashtable must have all three entries:

+ LdapFilter: The pattern for the SamAccountName of the admin account. This will be embedded in a fragment of the LDAP Filter searching for affected objects: `(samAccountName=%LdapFilter%)`. If this is done badly, it may fail to inspect the correct AD objects and not find all administrative user accounts.
+ Pattern: A regex pattern used in PowerShell script. All found user objects will have their SamAccountName matched against this to see, whether they are an administrative account that should have a paired, non-admin account.
+ Pair: A scriptblock that receives only the SamAccountName of the administrative account as input. It must return the name of the non-administrative account that should exist.

## Configuration

```powershell
@{
    AccountPair = @{
        Pairs = @(
            @{ LdapFilter = 'adm-*'; Pattern = '^adm-'; Pair = { $args[0] -replace '^adm-' } }
        )
    }
}
```
