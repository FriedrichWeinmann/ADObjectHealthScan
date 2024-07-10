# LastLogon

## Description

Scans for users who have not logged on within a given timerange.

## Object Class

+ Person
+ Computer

## Parameters

|Name|Type|Default|Description|
|---|---|---|---|
|LogonThreshold|int|180|The number of days, an account must not have logged in before it is considered unhealthy. The scan is precise to within 14 days, due to AD replication of the attribute.|

## Configuration

```powershell
@{
    LastLogon = @{
        LogonThreshold = 90
    }
}
```
