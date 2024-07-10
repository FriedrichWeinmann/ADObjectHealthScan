# PasswordChangeRequired

## Description

Scans for users who must change their password on next logon.
As this collides with accounts that have been created without a password, this test will only return a finding, if the account has already logged in.

## Object Class

+ Person

## Parameters

This check has no configuration options.

## Configuration

```powershell
@{
    PasswordChangeRequired = @{ }
}
```
