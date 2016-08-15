## 2.2.5
- Updated README.md to point to the swift 3 version

## 2.2.4
- New method `allItems`
- New properties `isSynchronized` and `accessGroup` which are passed to the keychain calls

## 2.2.3
- Fixed warning preventing publishing to CocoaPods

## 2.2.2
- `NSLog()` calls have been replaced with a programable severity based logger

## 2.2.1
- Removed Cartfile that was for testing

## 2.2.0
- Added shared frameworks for iOS, OS X, tvOS, watchOS
- The original RGLockboxFramework is now RGLockboxIOS

## 2.1.2
- Added a shared framework target to support Carthage

## 2.1.1
- Document comments added to all declarations.

## 2.1.0
- `valueCache` is now of type `[RGMultiKey:AnyObject]`
- `init(withNamespace:, accessibility:)` is now `init(withNamespace:, accessibility:, accountName:)`

## 2.0.2
- Fixed `keychainQueue` not being public which would prevent terminating apps from flushing their keychain I/O

## 2.0.1
- Added document comments to all items.
- `setJSONObject(_, key:)` is now correctly marked that it is `throws`.
- `JSONObjectForKey(_)` does not implicitly throw on some read inputs.

## 2.0.0
- Library has been rewritten in Swift
- Re-released as the pod `RGSwiftKeychain`

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

