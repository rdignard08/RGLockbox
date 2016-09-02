## 1.4.5
- New symbol `rg_dep_log` which is deprecated so that `RGLog` is also deprecated
- New symbol `rg_log_severity_v` is the non-variadic form of `rg_log_severity`

## 1.4.4
- New parameters `accessGroup` and `isSynchronized` used on platforms where available
- New initializer, old one is deprecated
- New method `allItems` to see all keys available to this manager
- The properties `namespace`, `accountName` are `copy` for safety purposes
- The symbol `rg_SecItemUpdate` is gone as the library logic is tweaked to delete->add 

## 1.4.3
- A new log facility `RGLogs()` is available to log based on a severity level
- `RGLog()` has the same behavior but uses the new log backend
- use `rg_set_logging_severity(RGLogSeverity)` to change the system log level

## 1.4.2
- Removed Cartfile that was for testing
- `+[RGLockbox manager]` now correctly does not return `instancetype`

## 1.4.1
- Removed some redundant framework files

## 1.4.0
- Removed target "RGLockboxFramework" which is migrated to "RGLockboxIOS"
- Added targets "RGLockboxTVOS", "RGLockboxWatch", "RGLockboxOSX"
- Noted in the podspec support for WatchOS 1.0

## 1.3.1
- Added a shared framework target to support Carthage

## 1.3.0
- initializer `initWithNamespace:accessibility:` is now `initWithNamespace:accessibility:accountName:`
- internally values are grouped by account if provided

## 1.2.2
- Provided a method to test what values are currently in the system wide keychain cache

## 1.2.1
- Updated podspec to refer to the Objective-C homepage

## 1.2.0
- Raises an exception when writing to the keychain and it is unavailable (usually due to password lock)
- Returns `nil` when the keychain is unavailable and will retry the key on the next request
- Uses limit one for the query to be slightly faster

## 1.1.1
- Will log in debug mode when the library is interacting with the system keychain
- Fixed a race condition where the in memory cache could get out of sync with the on disk keychain

## 1.1.0
- The exported symbol `rg_SecItemCopyMatching` has been renamed to `rg_SecItemCopyMatch` so to not run afoul of OCLint

## 1.0.3
- Expanded README.md to help users with more advanced use cases

## 1.0.2
- Update README.md to facilitate adoption of the library

## 1.0.1
- symbols `rg_SecItemCopyMatching`, `rg_SecItemAdd`, `rg_SecItemUpdate`, `rg_SecItemDelete` are exposed to allow runtime hooking

## 1.0.0
- Generally, all class methods are now instance methods
- Use `[RGLockbox manager]` to get the previous behavior
- You may initialize your own instance of `RGLockbox` with a custom namespace
- Implements internal caching to minimize disk hits
  - As a consequence you absolutely must not mix usage between this library and another implementation
  - Also you must `dispatch_sync` when your program is about to terminate
- Convenience methods are moved to their own category to minimize the main interface
- 100% branch coverage
- complete nullability annonations
- 100% on cocoadocs

