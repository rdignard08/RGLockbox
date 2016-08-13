/* Copyright (c) 01/27/2016, Ryan Dignard
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 1. Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
 ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. */

#import "RGLockbox.h"
#import <objc/runtime.h>
#import "NSObject+RGBadInit.h"
#import "RGMultiStringKey.h"

@interface RGLockbox (RGForwardDeclarations)

+ (NSMutableDictionary*)valueCache;

@end

static NSString* const kKey1 = @"aKey1";
static NSString* const kKey2 = @"aKey2";
static NSString* testKeys[] = { @"aKey1", @"aKey2" };

CLASS_SPEC(RGLockbox)

+ (void) load {
    rg_set_logging_severity(kRGLogSeverityTrace);
    initializeKeychain();
    rg_SecItemCopyMatch = &replacementItemCopy;
    rg_SecItemAdd = &replacementAddItem;
    rg_SecItemUpdate = &replacementUpdateItem;
    rg_SecItemDelete = &replacementDeleteItem;
}

- (void) tearDown {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:nil
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:nil];
    for (NSString* key in manager.allItems) {
        [manager setData:nil forKey:key];
    }
    dispatch_barrier_sync([RGLockbox keychainQueue], ^{});
    [[RGLockbox valueCache] removeAllObjects];
}

- (void) setUp {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:nil
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:nil];
    for (NSString* key in manager.allItems) {
        [manager setData:nil forKey:key];
    }
    dispatch_barrier_sync([RGLockbox keychainQueue], ^{});
    [[RGLockbox valueCache] removeAllObjects];
}

- (void) testBadInit {
    method_exchangeImplementations(class_getInstanceMethod([NSObject self], @selector(init)),
                                   class_getInstanceMethod([NSObject self], @selector(override_init)));
    RGLockbox* lockbox = [RGLockbox new];
    XCTAssert(lockbox == nil);
    method_exchangeImplementations(class_getInstanceMethod([NSObject self], @selector(init)),
                                   class_getInstanceMethod([NSObject self], @selector(override_init)));
}

#pragma mark - testCacheForKey
- (void) testCacheNil {
    id value = [[RGLockbox manager] testCacheForKey:kKey1];
    XCTAssert(value == nil);
}

- (void) testCacheNull {
    [[RGLockbox manager] dataForKey:kKey1];
    id value = [[RGLockbox manager] testCacheForKey:kKey1];
    XCTAssert(value == [NSNull null]);
}

- (void) testCacheData {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    id value = [[RGLockbox manager] testCacheForKey:kKey1];
    XCTAssert([value isEqual:[NSData new]]);
}

- (void) testCacheNoNamespace {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:nil
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:nil];
    [manager setData:[NSData new] forKey:@"com.abcd.www"];
    id value = [manager testCacheForKey:@"com.abcd.www"];
    XCTAssert([value isEqual:[NSData new]]);
    [manager setData:nil forKey:@"com.abcd.www"];
}

- (void) testReadWriteAccountName {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:@"com.rglockbox"
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:@"com.restgoatee.rglockbox"];
    [manager setData:[NSData new] forKey:@"abcd"];
    id value = [manager testCacheForKey:@"abcd"];
    XCTAssert([value isEqual:[NSData new]]);
    [[[manager class] valueCache] removeAllObjects];
    value = [manager dataForKey:@"abcd"];
    XCTAssert([value isEqual:[NSData new]]);
}

#pragma mark - Reading / Writing / Deleting
- (void) testReadNotExist {
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadNotExistDouble {
    [[RGLockbox manager] dataForKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadExist {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

- (void) testReadNotUnlocked {
    [[RGLockbox valueCache] removeAllObjects];
    rg_SecItemCopyMatch = &replacementItemCopyBad;
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert(data == nil);
    XCTAssert([RGLockbox valueCache][kKey1] == nil); // no cache
    rg_SecItemCopyMatch = &replacementItemCopy;
}

- (void) testReadExistDouble {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    [[RGLockbox manager] dataForKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

- (void) testReadNotSeen {
    NSString* key = [NSString stringWithFormat:@"%@.%@", [RGLockbox manager].namespace, kKey2];
    [[RGLockbox manager] setData:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey2];
    [[RGLockbox valueCache] removeObjectForKey:key];
    NSData* data = [[RGLockbox manager] dataForKey:kKey2];
    XCTAssert([data isEqual:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding]]);
}

- (void) testReadNoNameSpace {
    RGLockbox* rawAccess = [[RGLockbox alloc] initWithNamespace:nil accessibility:nil accountName:nil];
    [rawAccess setData:[@"abes" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"com.restgoatee.rglockbox.foobar"];
    NSData* data = [rawAccess dataForKey:@"com.restgoatee.rglockbox.foobar"];
    XCTAssert([data isEqual:[@"abes" dataUsingEncoding:NSUTF8StringEncoding]]);
}

#pragma mark - Updating
- (void) testUpdateValue {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:rg_bundle_identifier()
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:nil];
    dispatch_barrier_sync([RGLockbox keychainQueue], ^{});
    [manager setData:nil forKey:kKey1];
    dispatch_barrier_sync([RGLockbox keychainQueue], ^{});
    [[RGLockbox valueCache] removeAllObjects];
    [manager setData:[@"abew" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey1];
    [manager setData:[@"qwew" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey1];
    dispatch_barrier_sync([RGLockbox keychainQueue], ^{});
    RGMultiStringKey* fullKey = [RGMultiStringKey new];
    fullKey.first = [NSString stringWithFormat:@"%@.%@", manager.namespace, kKey1];
    [[RGLockbox valueCache] removeObjectForKey:fullKey];
    NSData* data = [manager dataForKey:kKey1];
    XCTAssert([data isEqual:[@"qwew" dataUsingEncoding:NSUTF8StringEncoding]]);
}

- (void) testAllItemsNamespaced {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    [[RGLockbox manager] setData:[NSData new] forKey:kKey2];
    NSMutableArray* keys = [@[ kKey1, kKey2 ] mutableCopy];
    NSArray* items = [RGLockbox manager].allItems;
    for (NSString* item in items) {
        XCTAssert([keys containsObject:item]);
        [keys removeObject:item];
    }
    XCTAssert(keys.count == 0);
}

- (void) testAllItemsNoNamespace {
    RGLockbox* manager = [[RGLockbox alloc] initWithNamespace:nil
                                                accessibility:kSecAttrAccessibleAlways
                                                  accountName:nil];
    [manager setData:[NSData new] forKey:[NSString stringWithFormat:@"%@.%@", rg_bundle_identifier(), kKey1]];
    [manager setData:[NSData new] forKey:[NSString stringWithFormat:@"%@.%@", rg_bundle_identifier(), kKey2]];
    NSMutableArray* keys = [@[ [NSString stringWithFormat:@"%@.%@", rg_bundle_identifier(), kKey1],
                               [NSString stringWithFormat:@"%@.%@", rg_bundle_identifier(), kKey2] ] mutableCopy];
    NSArray* items = manager.allItems;
    for (NSString* item in items) {
        XCTAssert([keys containsObject:item]);
        [keys removeObject:item];
    }
    XCTAssert(keys.count == 0);
}

- (void) testDescription {
    NSString* description = [RGLockbox manager].description;
    XCTAssert([description containsString:RG_STRING_SEL(namespace)]);
    XCTAssert([description containsString:RG_STRING_SEL(accountName)]);
    XCTAssert([description containsString:RG_STRING_SEL(accessGroup)]);
    XCTAssert([description containsString:RG_STRING_SEL(itemAccessibility)]);
    XCTAssert([description containsString:RG_STRING_SEL(isSynchronized)]);
}

SPEC_END
