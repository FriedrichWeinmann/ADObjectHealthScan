# BadEncryptionTypes

## Description

Scans for users whose Encryption types prevent modern AES modes.
This mostly affects users who have been forced into RC4 mode.

https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-kile/6cfc7b50-11ed-4b4d-846d-6f08f0812919

## Object Class

+ Person

## Configuration

```powershell
@{
    BadEncryptionTypes = @{}
}
```