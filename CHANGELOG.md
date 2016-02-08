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

