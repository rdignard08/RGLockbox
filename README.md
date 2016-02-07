[![Build Status](https://travis-ci.org/rdignard08/RGLockbox.svg?branch=master)](https://travis-ci.org/rdignard08/RGLockbox)
[![Coverage Status](https://codecov.io/github/rdignard08/RGLockbox/coverage.svg?branch=master)](https://codecov.io/github/rdignard08/RGLockbox?branch=master)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/rdignard08/RGLockbox)
[![Pod Version](https://img.shields.io/cocoapods/v/RGLockbox.svg)](https://cocoapods.org/pods/RGLockbox)
[![Pod Platform](http://img.shields.io/cocoapods/p/RGLockbox.svg?style=flat)](http://cocoadocs.org/docsets/RGLockbox/)
[![Pod License](http://img.shields.io/cocoapods/l/RGLockbox.svg?style=flat)](https://github.com/rdignard08/RGLockbox/blob/master/LICENSE)

RGLockbox
=======
RGLockbox is a simple to use interface with the standard keychain.  Using object-orientented approaches it is simple to pick a key and store any rudimentary value there.

Example
=======
```objc
NSData* data = [@"abcd" dataWithEncoding:NSUTF8StringEncoding];
RGLockbox* lockbox = [RGLockbox manager];
[lockbox setData:data forKey:@"myData"];
```
Writing data is as simple as creating it and applying it to your keychain manager.  By default these managers are namespaced to your bundle's identifier.

```objc 
NSData* data = [[RGLockbox manager] dataForKey:@"myData"];
NSString* string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
assert([string isEqual:@"abcd"]);
```
Retrieving data is as simple as remembering your key assuming you use the same manager throughout.  Mixing and matching managers with different namespaces is possible, but more of an advanced use case.

```objc
NSDate* date = [NSDate new];
[[RGLockbox manager] setDate:date forKey:@"myDate"];
```
In addition to the primitive interface supporting reading and writing raw `NSData` there is implicit support for a variety of types.

Installation
=======
Using cocoapods add `pod 'RGLockbox'` to your Podfile and run `pod install`

License
=======
BSD Simplied (2-clause)
