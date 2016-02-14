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
#import "RGDefines.h"
#import <Security/Security.h>

#ifdef DEBUG
    #define dNSLog(...) NSLog(__VA_ARGS__)
#else
    #define dNSLog(...)
#endif

NSString* RG_SUFFIX_NONNULL rg_bundle_identifier(void) {
    static NSString* _sBundleIdentifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sBundleIdentifier = [NSBundle bundleForClass:[RGLockbox self]].infoDictionary[(id)kCFBundleIdentifierKey];
    });
    return _sBundleIdentifier;
}

OSStatus (* RG_SUFFIX_NONNULL rg_SecItemCopyMatch)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                   CFTypeRef* RG_SUFFIX_NULLABLE) = &SecItemCopyMatching;
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemAdd)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                             CFTypeRef RG_SUFFIX_NULLABLE * RG_SUFFIX_NULLABLE) = &SecItemAdd;
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemUpdate)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                CFDictionaryRef RG_SUFFIX_NONNULL) = &SecItemUpdate;
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemDelete)(CFDictionaryRef RG_SUFFIX_NONNULL) = &SecItemDelete;

@implementation RGLockbox

+ (instancetype) manager {
    static dispatch_once_t onceToken;
    static id _sManager;
    dispatch_once(&onceToken, ^{
        _sManager = [self new];
    });
    return _sManager;
}

+ (RG_PREFIX_NONNULL dispatch_queue_t) keychainQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("RGLockbox-Sync", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

+ (RG_PREFIX_NONNULL NSLock*) valueCacheLock {
    static dispatch_once_t onceToken;
    static NSLock* _sValueCacheLock;
    dispatch_once(&onceToken, ^{
        _sValueCacheLock = [NSLock new];
    });
    return _sValueCacheLock;
}

+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(NSString*, id) *) valueCache {
    static dispatch_once_t onceToken;
    static NSMutableDictionary* _sValueCache;
    dispatch_once(&onceToken, ^{
        _sValueCache = [NSMutableDictionary new];
    });
    return _sValueCache;
}

- (RG_PREFIX_NONNULL instancetype) init {
    return [self initWithNamespace:rg_bundle_identifier() accessibility:nil];
}

- (RG_PREFIX_NONNULL instancetype) initWithNamespace:(RG_PREFIX_NULLABLE NSString*)namespace
                                       accessibility:(RG_PREFIX_NULLABLE CFStringRef)accessibility {
    self = [super init];
    if (self) {
        CFStringRef nonnullAccessibility = accessibility ?: kSecAttrAccessibleAfterFirstUnlock;
        self->_namespace = namespace;
        self->_itemAccessibility = nonnullAccessibility;
    }
    return self;
}

- (RG_PREFIX_NULLABLE NSData*) dataForKey:(RG_PREFIX_NONNULL NSString*)key {
    NSString* hierarchyKey = self.namespace ? [NSString stringWithFormat:@"%@.%@", self.namespace, key] : key;
    [[[self class] valueCacheLock] lock];
    id value = [[self class] valueCache][hierarchyKey];
    if (value) {
        [[[self class] valueCacheLock] unlock];
        return [value isKindOfClass:[NSData self]] ? value : nil;
    }
    __block CFTypeRef data = nil;
    dispatch_sync([[self class] keychainQueue], ^{
        NSDictionary* query = @{
                                (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService : hierarchyKey,
                                (__bridge id)kSecReturnData : @YES
                                };
        OSStatus status = rg_SecItemCopyMatch((__bridge CFDictionaryRef)query, &data);
        dNSLog(@"SecItemCopyMatching with %@ returned %@", query, @(status));
    });
    NSData* bridgedData = (__bridge_transfer NSData*)data; /* NSNull is a placeholder in the cache to say we've tried */
    [[self class] valueCache][hierarchyKey] = bridgedData ?: [NSNull null];
    [[[self class] valueCacheLock] unlock];
    return bridgedData;
}

- (void) setData:(RG_PREFIX_NULLABLE NSData*)object forKey:(RG_PREFIX_NONNULL NSString*)key {
    NSString* hierarchyKey = self.namespace ? [NSString stringWithFormat:@"%@.%@", self.namespace, key] : key;
    [[[self class] valueCacheLock] lock];
    [[self class] valueCache][hierarchyKey] = object ?: [NSNull null];
    [[[self class] valueCacheLock] unlock];
    dispatch_async([[self class] keychainQueue], ^{
        OSStatus status;
        NSMutableDictionary* query = [@{
                                        (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                        (__bridge id)kSecAttrService : hierarchyKey
                                        } mutableCopy];
        if (object) { /* Add or Update... */
            NSDictionary* payload = @{
                                      (__bridge id)kSecValueData : object,
                                      (__bridge id)kSecAttrAccessible : (__bridge id)self.itemAccessibility
                                      };
            [query addEntriesFromDictionary:payload];
            status = rg_SecItemAdd((__bridge CFDictionaryRef)query, NULL);
            dNSLog(@"SecItemAdd with %@ returned %@", query, @(status));
            if (status == errSecDuplicateItem) { /* Duplicate so update */
                status = rg_SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)payload);
                dNSLog(@"SecItemUpdate with %@ and %@ returned %@", query, payload, @(status));
            }
            return;
        } /* Not Add or Update, must be delete */
        status = rg_SecItemDelete((__bridge CFDictionaryRef)query);
        dNSLog(@"SecItemDelete with %@ returned %@", query, @(status));
    });
}

@end
