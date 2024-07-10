# EmptyGroup

## Description

Scans for groups that have no members.
By default, this will skip builtin and admin groups.

## Object Class

+ Group

## Parameters

|Name|Type|Default|Description|
|---|---|---|---|
|ExcludeBuiltIn|bool|$true|Whether to exclude builtin groups that come with Active Directory in this scan|
|ExcludeAdminGroups|bool|$true|Whether to exclude sensitive groups (those flagged ith the AdminCount attribute) from the scan|

## Configuration

```powershell
@{
    EmptyGroup = @{
        ExcludeBuiltIn = $true
        ExcludeAdminGroups = $true
    }
}
```
