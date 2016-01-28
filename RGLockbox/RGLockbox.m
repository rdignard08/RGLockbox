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

static NSString* const _sIsoFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";

static NSString* rg_bundle_identifier(void) {
    static NSString* _sBundleIdentifier;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sBundleIdentifier = [NSBundle bundleForClass:[RGLockbox self]].infoDictionary[(id)kCFBundleIdentifierKey];
    });
    return _sBundleIdentifier;
}

static void rg_delete_data_for_key(CFStringRef key) {
    NSDictionary* query = @{ (id)kSecClass : (id)kSecClassGenericPassword, (id)kSecAttrService : (__bridge id)key };
    SecItemDelete((__bridge CFDictionaryRef)query);
}

static void rg_update_data_for_key(CFDataRef data, CFDictionaryRef itemQuery, CFStringRef accessibility) {
    CFTypeRef keys[] = { kSecValueData, kSecAttrAccessible };
    CFTypeRef values[] = { data, accessibility };
    CFDictionaryRef update = CFDictionaryCreate(nil, keys, values, sizeof(keys), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    SecItemUpdate(itemQuery, update);
    CFRelease(update);
}

static void rg_set_data_for_key(CFDataRef data, CFStringRef key, CFStringRef accessibility) {
    NSDictionary* query = @{ (id)kSecClass : (id)kSecClassGenericPassword, (id)kSecAttrService : (__bridge id)key, (id)kSecValueData : (__bridge id)data, (id)kSecAttrAccessible : (__bridge id)accessibility };
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    if (status == errSecDuplicateItem) {
        rg_update_data_for_key(data, (__bridge CFDictionaryRef)query, accessibility);
    }
}

@implementation RGLockbox

+ (instancetype) manager {
    static dispatch_once_t onceToken;
    static id _sManager;
    dispatch_once(&onceToken, ^{
        _sManager = [self new];
    });
    return _sManager;
}

+ (dispatch_queue_t) keychainQueue {
    static dispatch_once_t onceToken;
    static dispatch_queue_t queue;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("RGLockbox-Sync", DISPATCH_QUEUE_SERIAL);
    });
    return queue;
}

- (instancetype) init {
    return [self initWithNamespace:rg_bundle_identifier() accessibility:kSecAttrAccessibleAfterFirstUnlock];
}

- (instancetype) initWithNamespace:(NSString*)namespace accessibility:(CFStringRef)accessibility {
    self = [super init];
    if (self) {
        self->_namespace = namespace;
        self->_itemAccessibility = accessibility;
    }
    return self;
}

- (NSData*) objectForKey:(NSString*)key {
    NSString* hierarchyKey = self.namespace ? [NSString stringWithFormat:@"%@.%@", self.namespace, key] : key;
    NSDictionary* query = @{ (id)kSecClass : (id)kSecClassGenericPassword, (id)kSecAttrService : hierarchyKey, (id)kSecReturnData : @YES };
    CFTypeRef data = nil;
    SecItemCopyMatching((__bridge CFDictionaryRef)query, &data);
    return (__bridge_transfer NSData*)data;
}

- (void) setObject:(NSData*)object forKey:(NSString*)key {
    [self setObject:object forKey:key withAccessibility:self.itemAccessibility];
}

- (void) setObject:(NSData*)object forKey:(NSString*)key withAccessibility:(CFStringRef)accessibility {
    NSString* hierarchyKey = self.namespace ? [NSString stringWithFormat:@"%@.%@", self.namespace, key] : key;
    CFStringRef cfKey = (__bridge CFStringRef)hierarchyKey;
    CFDataRef cfData = (__bridge CFDataRef)object;
    object ? rg_set_data_for_key(cfData, cfKey, accessibility) : rg_delete_data_for_key(cfKey);
}

@end
