# Creating your own Checks

Creating your own custom checks is not terribly hard to do and requires registering them using the `Register-AhsCheck` command.

## Example Check

Here a quick example check for reference:

```powershell
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
```

## Parameters Explained

> Name

The name of the check.
It must be unique, in case of collision, the new check will overwrite the old one.

> Check

The scriptblock applied to all found principal objects.
It receives three arguments (in this order):

+ ADObject: The Active Directory object to be checked, whether the finding applies.
+ Config: The effective configuration-settings for this check. A Hashtable.
+ ADParam: A hashtable containing the AD connection information, in case the check needs to request more information from AD.

If the checked object is healthy, this scriptblock should return nothing.
If it is not so, a new finding should be generated using `New-AhsFinding` with the following parameters:

+ Check: Name of the check calling it.
+ Threshold: The expected/minimum/maximum value.
+ Value: The actual value.
+ ADObject: The AD object failing the check.

Tip: When providing Threshold and Value, consider what the user would expect logically from this test and not necessarily the technically precise value.
In the example case above, _technically_ we check whether the value 65536 is included as a flag in the UserAccountControl.
_Logically_ however we check, whether the account is set to have its password never expire (which is a truth statement).

> LdapFilter

A scriptblock that generates the LdapFilter-Fragment for this check.
When performing a scan using `Invoke-AhsCheck`, all applicable checks are called for each object class scanned and all fragments are merged into one big LDAP Filter statement.

Since some filter statements depend on the configuration and other factors (such as the current time, to determine how far back into the past to look), this is a scriptblock that will be executed and needs to return a piece of string.
It will receive a single argument - the hashtable containing the effective configuration.

As the object class being scanned is handled externally, this ldap filter need not take it into consideration.

> ObjectClass

The list of object classes this filter applies to.
Actually, these are matched to the property _ObjectCategory_ in the ldap filters, but common admin usage mostly uses the word ObjectClass, hence the name.

Can contain multiple values - e.g.: `'Person','Computer'`.

> Properties

The properties needed on the object.
Any properties your `Check` code uses on the object should be requested here, as otherwise it may be missing on the tested object.

Similar to `ObjectClass`, multiple values can be provided.

> Description

A description that explains to the user, what the check is intended to do.
Documentation only.

> Parameters

A hashtable of the parameters supported by the check and the default value for each.
Example:

```powershell
    Parameters  = @{
        ExcludeAdminGroups = $true
        ExcludeBuiltIn = $true
    }
```
