# NoPasswordNeeded

## Description

Scans for users who are configured to not require a password.
This is a flag on the [UserAccountControl](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties) attribute that is usually considered undesired.

## Object Class

+ Person

## Parameters

This check has no configuration options.

## Configuration

```powershell
@{
    NoPasswordNeeded = @()
}
```
