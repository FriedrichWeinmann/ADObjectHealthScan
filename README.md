# Active Directory Object Health Scan

Welcome to the Project Site for the Active Directory Object Health Scan tool.
If you are looking to scan your principals for a healthy configuration, this place is for you.

This PowerShell-based project offers a way to run health scans against objects in AD, trying to find any with health issues.
It also allows a simple way to extend the available checks with your own check-logic.

## Installation

```powershell
Install-Module ADObjectHealthScan -Scope CurrentUser
```

or on PowerShell v7.4+:

```powershell
Install-PSResource ADObjectHealthScan
```

## Profit

A quick scan with the default settings will show all objects that violate any of the check's requirements using the default settings:

```powershell
Invoke-AhsCheck -All
```

To get a list of checks and their available options, run this:

```powershell
Get-AhsCheck
```

```text
Name                   ObjectClass      Parameters                         Description
----                   -----------      ----------                         -----------
EmptyGroup             Group            ExcludeBuiltIn, ExcludeAdminGroups Scans for groups that have no members.
NeverLoggedIn          Person           CreationGrace                      Scans for users whose password has not been set within the required t…
BadEncryptionTypes     Person                                              Scans for users whose password has not been set within the required t…
OldPassword            Person           PasswordThreshold                  Scans for users whose password has not been set within the required t…
PasswordChangeRequired Person                                              Scans for users who must change their password on next logon.
NoPasswordNeeded       Person                                              Scans for users who are configured to not require a password.
PasswordNeverExpires   Person                                              Scans for users whose password has been set to never expire.
LastLogon              Person, Computer LogonThreshold                     Scans for users who have not logged on within a given timerange
AccountPair            Person           Pairs                              Ensures a matching accounts exists. Use to catch accounts that should…
```

To run a specific check with a specific configuration, this can easily be done like this:

```powershell
Invoke-AhsCheck -Configuration @{ LastLogon = @{ LogonThreshold = 14 } }
```

> Fancy Reports

You can generate a report out of those findings with `Export-AhsHealthReport`.
This command requires another module that is not part of the dependencies otherwise: `ImportExcel`:

```powershell
Install-Module ImportExcel -Scope CurrentUser
```

```powershell
Invoke-AhsCheck -All | Export-AhsHealthReport -Path .\adobjecthealth.xlsx
```

## Configuration File

It is possible to store all settings in a configuration file and provide that as input.
[Here is an example config file](docs/example.config.psd1) that shows how that would look.

There are three generic options:

+ _All: When set to true, all checks will be performed by default, even when no configuration is provided.
+ _ObjectClasses: Only the defined object classes will be scanned. By default, all object classes that have a check will be scanned. For example, if a check could be applied to both persons and computers, it will lead to both being checked, unless this setting constrains that.
+ _SearchRoot: The OU under which this module will search for objects to scan. By default, all objects in the domain are under scope.

Other than that, you can provide a set of settings, depending on which check you want to perform.
If `_All` is not defined, only checks that have been configured here will be executed.
This section also allows you to provide parameters to how those scans should perform, as some checks allow customizing their behavior, such as the `LastLogon` scan allowing, how many days into the past is permissible before a finding is generated.

Once that is all prepared, the scan can easily be executed like this:

```powershell
Invoke-AhsCheck -ConfigFile .\adobjecthealth.config.psd1
```

Or turned straight into a finished report:

```powershell
Invoke-AhsCheck -ConfigFile .\adobjecthealth.config.psd1 | Export-AhsHealthReport -Path .\adobjecthealth.xlsx
```

## Default Checks

This module comes with a few pre-defined checks:

|Name|Object Class|Parameters|Description|
|---|---|---|---|
|[AccountPair](docs/AccountPair.md)|Person|Pairs|Ensures a matching accounts exists. Use to catch accounts that should have a matching pair but don't.|
|[BadEncryptionTypes](docs/BadEncryptionTypes.md)|Person||Scans for users whose password has not been set within the required time.|
|[EmptyGroup](docs/EmptyGroup.md)|Group|ExcludeBuiltIn, ExcludeAdminGroups|Scans for groups that have no members.|
|[LastLogon](docs/LastLogon.md)|Person, Computer|LogonThreshold|Scans for users who have not logged on within a given timerange|
|[NeverLoggedIn](docs/NeverLoggedIn.md)|Person|CreationGrace|Scans for users whose password has not been set within the required time.|
|[NoPasswordNeeded](docs/NoPasswordNeeded.md)|Person||Scans for users who are configured to not require a password.|
|[OldPassword](docs/OldPassword.md)|Person|PasswordThreshold|Scans for users whose password has not been set within the required time.|
|[PasswordChangeRequired](docs/PasswordChangeRequired.md)|Person||Scans for users who must change their password on next logon.|
|[PasswordNeverExpires](docs/PasswordNeverExpires.md)|Person||Scans for users whose password has been set to never expire.|
