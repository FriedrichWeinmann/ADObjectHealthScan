# OldPassword

## Description

Scans for users whose password has not been set within the required time.

## Object Class

+ Person

## Parameters

|Name|Type|Default|Description|
|---|---|---|---|
|PasswordThreshold|int|180|How many days ago the last password change may have occured, before triggering this check.|

## Configuration

```powershell
@{
    OldPassword = @{
        PasswordThreshold = 360
    }
}
```
