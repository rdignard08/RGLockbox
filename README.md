[![Build Status](https://travis-ci.org/rdignard08/RGLockbox.svg?branch=master)](https://travis-ci.org/rdignard08/RGLockbox)
[![Coverage Status](https://codecov.io/github/rdignard08/RGLockbox/coverage.svg?branch=objc-master)](https://codecov.io/github/rdignard08/RGLockbox?branch=objc-master)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/rdignard08/RGLockbox)
[![Pod Version](https://img.shields.io/cocoapods/v/RGLockbox.svg)](https://cocoapods.org/pods/RGLockbox)
[![Pod Platform](http://img.shields.io/cocoapods/p/RGLockbox.svg?style=flat)](http://cocoadocs.org/docsets/RGLockbox/)
[![Pod License](http://img.shields.io/cocoapods/l/RGLockbox.svg?style=flat)](https://github.com/rdignard08/RGLockbox/blob/master/LICENSE)
[![Readme Score](http://readme-score-api.herokuapp.com/score.svg?url=rdignard08/rglockbox)](http://clayallsopp.github.io/readme-score?url=rdignard08/rglockbox)

RGLockbox
=======
RGLockbox is a simple to use interface with the standard keychain.  Using object-orientented approaches it is simple to pick a key and store any rudimentary value there.

The Swift version of this pod is named `RGSwiftKeychain` and is available on the branch [swift-master](https://github.com/rdignard08/RGLockbox/tree/swift-master).

Default supported types include:
- `NSData`
- `NSString`
- `NSDate`
- `NSDictionary`
- `NSArray`
- `id<NSCoding>`
  - `NSURL`
  - `NSValue` (including `NSNumber` and `NSDecimalNumber`)
  - `NSNull`

Note for safety Apple encourages developers to conform their objects to `NSSecureCoding` instead of `NSCoding` to prevent substitution attacks against your app.

Example
=======
```objc
NSData* data = [@"abcd" dataWithEncoding:NSUTF8StringEncoding];
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setData:data forKey:@"myData"];
```
Writing data is as simple as creating it and applying it to your keychain manager.  By default these managers are namespaced to your bundle's identifier.

```objc 
RGLockbox* lockbox = [RGLockbox manager];
NSData* data = [lockbox dataForKey:@"myData"];
NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
assert([string isEqual:@"abcd"]);
```
Retrieving data is as simple as remembering your key assuming you use the same manager throughout.  Mixing and matching managers with different namespaces is possible, but more of an advanced use case.

In addition to the primitive interface supporting reading and writing raw `NSData` there is implicit support for a variety of types.
`NSDate`:
```objc
NSDate* date = [NSDate new];
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setDate:date forKey:@"myDate"];
NSDate* readDate = [lockbox dateForKey:@"myDate"];
assert([readDate timeIntervalSince1970] == [date timeIntervalSince1970]);
```
`NSString`:
```objc
NSString* string = @"aString";
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setString:string forKey:@"stringKey"];
NSString* readString = [lockbox stringForKey:@"stringKey"];
assert([readString isEqual:string]);
```
`NSDictionary`:
```objc
NSDictionary* dictionary = @{ @"aKey" : @"aValue" };
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setJSONObject:dictionary forKey:@"dictionaryKey"];
NSDictionary* readDictionary = [lockbox JSONObjectForKey:@"dictionaryKey"];
assert([readDictionary isEqual:dictionary]);
```
`NSArray`:
```objc
NSArray* array = @[ @"aValue1", @"aValue2" ];
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setJSONObject:array forKey:@"arrayKey"];
NSArray* readArray = [lockbox JSONObjectForKey:@"arrayKey"];
assert([readArray isEqual:array]);
```
`id<NSCoding>`:
```objc
NSURL* url = [NSURL URLWithString:@"google.com"];
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setCodeable:url forKey:@"urlKey"];
NSURL* readURL = [lockbox codeableForKey:@"urlKey"];
assert([readURL isEqual:url]);
```

Finally, this library supports arbitrary namespacing which allows sharing keychain data across app bundles as well as setting different item accessibility for advanced use cases.
```objc
NSDate* signupDate = [NSDate dateWithTimeIntervalSince1970:1453075980.0];
RGLockbox* lockbox = [[RGLockbox alloc] initWithNamespace:@"com.rglockbox.appbundle" accessibility:kSecAttrAccessibleAlways];
[lockbox setDate:signup forKey:@"userSignupDate"];
/* In another program, app extension, component framework, etc. ... */
RGLockbox* lockbox = [[RGLockbox alloc] initWithNamespace:@"com.rglockbox.appbundle" accessibility:kSecAttrAccessibleAlways];
NSDate* signupDate = [lockbox dateForKey:@"userSignupDate"];
assert([signupDate timeIntervalSince1970] == 1453075980.0);
```

Installation
=======
Using cocoapods add `pod 'RGLockbox'` to your Podfile and run `pod install`

License
=======
BSD Simplied (2-clause)
