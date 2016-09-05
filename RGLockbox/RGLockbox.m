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
#import <Security/Security.h>
#import <objc/runtime.h>

#if TARGET_OS_IOS || TARGET_OS_TV
    #import <UIKit/UIKit.h>
#endif

#pragma mark - Swizzle
static void rg_swizzle(Class RG_SUFFIX_NULLABLE cls, SEL RG_SUFFIX_NULLABLE original, SEL RG_SUFFIX_NULLABLE replace) {
    IMP replacementImp = method_setImplementation(class_getInstanceMethod(cls, replace),
                                                  class_getMethodImplementation(cls, original));
    // get the replacement IMP
    // we assume swizzle is called on the class with replacement, so we can safety force original onto replacement
    // set the original IMP on the replacement selector
    // try to add the replacement IMP directly to the class on original selector
    // if it succeeds then we're all good (the original before was located on the superclass)
    // if it doesn't then that means an IMP is already there so we have to overwrite it
    method_setImplementation(class_getInstanceMethod(cls, original), replacementImp);
}

#pragma mark - Bundle Identifier
static NSString* _sBundleIdentifier;
static NSString* RG_SUFFIX_NONNULL override_rg_bundle_identifier(void) {
    return _sBundleIdentifier;
}

static NSString* RG_SUFFIX_NONNULL backing_rg_bundle_identifier(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sBundleIdentifier = [NSBundle bundleForClass:[RGLockbox self]].infoDictionary[(id)kCFBundleIdentifierKey];
        rg_bundle_identifier = override_rg_bundle_identifier;
    });
    return _sBundleIdentifier;
}
NSString* RG_SUFFIX_NONNULL (* RG_SUFFIX_NONNULL rg_bundle_identifier)(void) = backing_rg_bundle_identifier;

static RGMultiStringKey* RG_SUFFIX_NONNULL rg_multi_key(NSString* RG_SUFFIX_NULLABLE nameSpace,
                                                        NSString* RG_SUFFIX_NULLABLE key,
                                                        NSString* RG_SUFFIX_NULLABLE accountName,
                                                        NSString* RG_SUFFIX_NULLABLE accessGroup) {
    RGMultiStringKey* ret = [RGMultiStringKey new];
    ret.first = nameSpace ? [NSString stringWithFormat:@"%@.%@", nameSpace, key] : key;
    ret.second = accountName;
    ret.third = accessGroup;
    return ret;
}

static NSMutableDictionary* RG_SUFFIX_NONNULL rg_generic_query(RGMultiStringKey* RG_SUFFIX_NULLABLE key) {
    NSMutableDictionary* query = [@{
                                    (__bridge id)kSecClass : (__bridge id)kSecClassGenericPassword,
                                    rg_synchronizable_key() : rg_synchronizable_any()
                                    } mutableCopy];
    if (key.first) {
        query[(__bridge id)kSecAttrService] = key.first;
    }
    if (key.second) {
        query[(__bridge id)kSecAttrAccount] = key.second;
    }
    if (key.third) {
        query[rg_accessgroup_key()] = key.third;
    }
    return query;
}

#pragma mark - Global Symbols
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemCopyMatch)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                   CFTypeRef* RG_SUFFIX_NULLABLE) = &SecItemCopyMatching;
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemAdd)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                             CFTypeRef RG_SUFFIX_NULLABLE * RG_SUFFIX_NULLABLE) = &SecItemAdd;
OSStatus (* RG_SUFFIX_NONNULL rg_SecItemDelete)(CFDictionaryRef RG_SUFFIX_NONNULL) = &SecItemDelete;

NSString* RG_SUFFIX_NONNULL RGApplicationWillResignActive;
NSString* RG_SUFFIX_NONNULL RGApplicationWillBackground;
NSString* RG_SUFFIX_NONNULL RGApplicationWillTerminate;

#pragma mark - RGLockbox Implementation
@implementation RGLockbox

+ (void) load {
#if TARGET_OS_IOS || TARGET_OS_TV
    RGApplicationWillResignActive = UIApplicationWillResignActiveNotification;
    RGApplicationWillBackground = UIApplicationDidEnterBackgroundNotification;
    RGApplicationWillTerminate = UIApplicationWillTerminateNotification;
#elif TARGET_OS_WATCH
    RGApplicationWillResignActive = @"UIApplicationWillResignActiveNotification";
    RGApplicationWillBackground = @"UIApplicationDidEnterBackgroundNotification";
    RGApplicationWillTerminate = @"UIApplicationWillTerminateNotification";
#elif TARGET_OS_MAC
    RGApplicationWillResignActive = @"NSApplicationWillResignActiveNotification";
    RGApplicationWillBackground = @"NSApplicationWillHideNotification";
    RGApplicationWillTerminate = @"NSApplicationWillTerminateNotification";
#else
#warning "Unknown platform target"
    RGApplicationWillResignActive = @"RGApplicationWillResignActive";
    RGApplicationWillBackground = @"RGApplicationWillBackground";
    RGApplicationWillTerminate = @"RGApplicationWillTerminate";
#endif
}

+ (void) initialize {
    [super initialize];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flushQueue:)
                                                 name:RGApplicationWillResignActive
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flushQueue:)
                                                 name:RGApplicationWillBackground
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(flushQueue:)
                                                 name:RGApplicationWillTerminate
                                               object:nil];
}

+ (void) flushQueue:(NSNotification*)notification {
    RGLogs(kRGLogSeverityTrace, @"flushQueue: called on %@", notification.name);
    dispatch_barrier_sync(self.keychainQueue, ^{});
}

+ (RGLockbox*) manager {
    static dispatch_once_t onceToken;
    static RGLockbox* _sManager;
    dispatch_once(&onceToken, ^{
        _sManager = [RGLockbox new];
    });
    return _sManager;
}

#pragma mark - keychainQueue
static dispatch_queue_t _sQueue;
+ (RG_PREFIX_NONNULL dispatch_queue_t) keychainQueue {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sQueue = dispatch_queue_create("RGLockbox-Sync", DISPATCH_QUEUE_SERIAL);
        rg_swizzle(objc_getMetaClass("RGLockbox"), @selector(keychainQueue), @selector(override_keychainQueue));
    });
    return _sQueue;
}

+ (RG_PREFIX_NONNULL dispatch_queue_t) override_keychainQueue {
    return _sQueue;
}

#pragma mark - valueCacheLock
static NSLock* _sValueCacheLock;
+ (RG_PREFIX_NONNULL NSLock*) valueCacheLock {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sValueCacheLock = [NSLock new];
        rg_swizzle(objc_getMetaClass("RGLockbox"), @selector(valueCacheLock), @selector(override_valueCacheLock));
    });
    return _sValueCacheLock;
}

+ (RG_PREFIX_NONNULL NSLock*) override_valueCacheLock {
    return _sValueCacheLock;
}

#pragma mark - valueCache
static NSMutableDictionary* _sValueCache;
+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(RGMultiStringKey*, id) *) valueCache {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sValueCache = [NSMutableDictionary new];
        rg_swizzle(objc_getMetaClass("RGLockbox"), @selector(valueCache), @selector(override_valueCache));
    });
    return _sValueCache;
}

+ (RG_PREFIX_NONNULL NSMutableDictionary RG_GENERIC(RGMultiStringKey*, id) *) override_valueCache {
    return _sValueCache;
}

#pragma mark - Public Methods
- (RG_PREFIX_NONNULL instancetype) init {
    return [self initWithNamespace:rg_bundle_identifier()
                     accessibility:nil
                       accountName:nil
                       accessGroup:nil
                      synchronized:NO];
}

- (RG_PREFIX_NONNULL instancetype) initWithNamespace:(RG_PREFIX_NULLABLE NSString*)nameSpace
                                       accessibility:(RG_PREFIX_NULLABLE CFStringRef)accessibility
                                         accountName:(RG_PREFIX_NULLABLE NSString*)account {
    return [self initWithNamespace:nameSpace
                     accessibility:accessibility
                       accountName:account
                       accessGroup:nil
                      synchronized:NO];
}

- (RG_PREFIX_NONNULL instancetype) initWithNamespace:(RG_PREFIX_NULLABLE NSString*)nameSpace
                                       accessibility:(RG_PREFIX_NULLABLE CFStringRef)accessibility
                                         accountName:(RG_PREFIX_NULLABLE NSString*)account
                                         accessGroup:(RG_PREFIX_NULLABLE NSString*)accessGroup
                                        synchronized:(BOOL)synchronized {
    self = [super init];
    if (self) {
        CFStringRef nonnullAccessibility = accessibility ?: rg_accessibility_default();
        self->_namespace = [nameSpace copy];
        self->_itemAccessibility = nonnullAccessibility;
        self->_accountName = [account copy];
        self->_accessGroup = [accessGroup copy];
        self->_isSynchronized = synchronized;
    }
    return self;
}

- (RG_PREFIX_NULLABLE id) testCacheForKey:(RG_PREFIX_NONNULL NSString*)key {
    [[[self class] valueCacheLock] lock];
    id value = [[self class] valueCache][rg_multi_key(self.namespace, key, self.accountName, self.accessGroup)];
    [[[self class] valueCacheLock] unlock];
    return value;
}

- (RG_PREFIX_NULLABLE NSData*) dataForKey:(RG_PREFIX_NONNULL NSString*)key {
    RGMultiStringKey* fullKey = rg_multi_key(self.namespace, key, self.accountName, self.accessGroup);
    [[[self class] valueCacheLock] lock];
    id value = [[self class] valueCache][fullKey];
    if (value) {
        [[[self class] valueCacheLock] unlock];
        return [value isKindOfClass:[NSData self]] ? value : nil;
    }
    __block CFTypeRef data = nil;
    __unused __block OSStatus status;
    dispatch_sync([[self class] keychainQueue], ^{
        NSMutableDictionary* query = rg_generic_query(fullKey);
        query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitOne;
        query[(__bridge id)kSecReturnData] = @YES;
        status = rg_SecItemCopyMatch((__bridge CFDictionaryRef)query, &data);
        RGLogs(kRGLogSeverityTrace, @"SecItemCopyMatching with %@ returned %@", query, @(status));
    });
    NSData* bridgedData = (__bridge_transfer NSData*)data;
    if (status != errSecInteractionNotAllowed) { /* Not allowed means we need to try again so don't cache NSNull */
        [[self class] valueCache][fullKey] = bridgedData ?: [NSNull null];
    } /* NSNull is a placeholder in the cache to say we've tried */
    [[[self class] valueCacheLock] unlock];
    return bridgedData;
}

- (RG_PREFIX_NONNULL NSArray RG_GENERIC(NSString *) *) allItems {
    RGMultiStringKey* fullKey = rg_multi_key(nil, nil, self.accountName, self.accessGroup);
    NSString* nameSpace = self.namespace;
    NSMutableArray RG_GENERIC(NSString *) * output = [NSMutableArray new];
    [[[self class] valueCacheLock] lock];
    __block CFTypeRef items = nil;
    dispatch_sync([[self class] keychainQueue], ^{
        NSMutableDictionary* query = rg_generic_query(fullKey);
        query[(__bridge id)kSecMatchLimit] = (__bridge id)kSecMatchLimitAll;
        query[(__bridge id)kSecReturnAttributes] = @YES;
        query[(__bridge id)kSecReturnData] = @YES;
        OSStatus status = rg_SecItemCopyMatch((__bridge CFDictionaryRef)query, &items);
        RGLogs(kRGLogSeverityTrace, @"SecItemCopyMatching with %@ returned %@", query, @(status));
        NSAssert(status != errSecInteractionNotAllowed, @"Keychain item unavailable, change itemAccessibility");
    });
    NSArray RG_GENERIC(NSDictionary *) * bridgedArray = (__bridge_transfer NSArray*)items;
    for (NSUInteger i = 0; i < bridgedArray.count; i++) {
        RGMultiStringKey *itemKey = [RGMultiStringKey new];
        id service = bridgedArray[i][(__bridge id)kSecAttrService];
        if (service) {
            NSAssert([service isKindOfClass:[NSString self]], @"Wrong type");
            itemKey.first = service;
        }
        id account = bridgedArray[i][(__bridge id)kSecAttrAccount];
        if (account) {
            NSAssert([account isKindOfClass:[NSString self]], @"Wrong type");
            itemKey.second = account;
        }
        id accessGroup = bridgedArray[i][rg_accessgroup_key()];
        if (accessGroup) {
            NSAssert([accessGroup isKindOfClass:[NSString self]], @"Wrong type");
            itemKey.third = accessGroup;
        }
        id data = bridgedArray[i][(__bridge id)kSecValueData];
        [[self class] valueCache][itemKey] = data ?: [NSNull null];
        if (service && !nameSpace) {
            [output addObject:service];
        } else if ([service hasPrefix:nameSpace]) {
            NSRange range = [service rangeOfString:nameSpace];
            [output addObject:[service substringFromIndex:range.location + range.length + 1]];
        }
    }
    [[[self class] valueCacheLock] unlock];
    return output;
}

- (void) setData:(RG_PREFIX_NULLABLE NSData*)object forKey:(RG_PREFIX_NONNULL NSString*)key {
    RGMultiStringKey* fullKey = rg_multi_key(self.namespace, key, self.accountName, self.accessGroup);
    [[[self class] valueCacheLock] lock];
    [[self class] valueCache][fullKey] = object ?: [NSNull null];
    dispatch_async([[self class] keychainQueue], ^{
        NSMutableDictionary* query = rg_generic_query(fullKey);
        OSStatus status = rg_SecItemDelete((__bridge CFDictionaryRef)query);
        RGLogs(kRGLogSeverityTrace, @"SecItemDelete with %@ returned %@", query, @(status));
        NSAssert(status != errSecInteractionNotAllowed, @"Keychain item unavailable, change itemAccessibility");
        if (object) { /* Add it */
            [query addEntriesFromDictionary:@{
                                              (__bridge id)kSecValueData : object,
                                              rg_accessibility_key() : (__bridge id)self.itemAccessibility,
                                              rg_synchronizable_key() : @(self.isSynchronized)
                                              }];
            status = rg_SecItemAdd((__bridge CFDictionaryRef)query, NULL);
            RGLogs(kRGLogSeverityTrace, @"SecItemAdd with %@ returned %@", query, @(status));
            NSAssert(status != errSecInteractionNotAllowed, @"Keychain item unavailable, change itemAccessibility");
        }
    });
    [[[self class] valueCacheLock] unlock];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"%@\n\tnamespace:%@"
                                      @"\n\taccountName:%@"
                                      @"\n\taccessGroup:%@"
                                      @"\n\titemAccessibility:%@"
                                      @"\n\tisSynchronized:%@",
                                      super.description,
                                      self.namespace,
                                      self.accountName,
                                      self.accessGroup,
                                      self.itemAccessibility,
                                      @(self.isSynchronized)];
}

@end
