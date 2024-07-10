# PasswordNeverExpires

## Description

Scans for users whose password has been set to never expire.
Generally, an account with this flag is vulnerable to an extended period of compromise, as an attacker will have near unlimited time to break the password and then use it.

## Object Class

+ Person

## Parameters

This check has no configuration options.

## Configuration

```powershell
@{
    PasswordNeverExpires = @{ }
}
```
