# NeverLoggedIn

## Description

Scans for users who have never logged in.

## Object Class

+ Person

## Parameters

|Name|Type|Default|Description|
|---|---|---|---|
|CreationGrace|int|30|Days after account creation a user has to log in, before the account is flagged.|

## Configuration

```powershell
@{
    NeverLoggedIn = @{
        CreationGrace = 60
    }
}
```
