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
    CFTypeRef keys[] = { kSecClass, kSecAttrService };
    CFTypeRef values[] = { kSecClassGenericPassword, key };
    CFDictionaryRef query = CFDictionaryCreate(nil, keys, values, sizeof(keys), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    SecItemDelete(query);
    CFRelease(query);
}

static void rg_update_data_for_key(CFDataRef data, CFDictionaryRef itemQuery, CFStringRef accessibility) {
    CFTypeRef keys[] = { kSecValueData, kSecAttrAccessible };
    CFTypeRef values[] = { data, accessibility };
    CFDictionaryRef update = CFDictionaryCreate(nil, keys, values, sizeof(keys), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    SecItemUpdate(itemQuery, update);
    CFRelease(update);
}

static void rg_set_data_for_key(CFDataRef data, CFStringRef key, CFStringRef accessibility) {
    CFTypeRef keys[] = { kSecClass, kSecAttrService, kSecValueData, kSecAttrAccessible };
    CFTypeRef values[] = { kSecClassGenericPassword, key, data, accessibility };
    CFDictionaryRef query = CFDictionaryCreate(nil, keys, values, sizeof(keys), &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    OSStatus status = SecItemAdd(query, NULL);
    if (status == errSecDuplicateItem) {
        rg_update_data_for_key(data, query, accessibility);
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

- (instancetype) init {
    return [self initWithNamespace:rg_bundle_identifier() accessibility:(__bridge NSString*)kSecAttrAccessibleAfterFirstUnlock];
}

- (instancetype) initWithNamespace:(NSString*)namespace accessibility:(NSString*)accessibility {
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
    NSString* hierarchyKey = self.namespace ? [NSString stringWithFormat:@"%@.%@", self.namespace, key] : key;
    CFStringRef cfKey = (__bridge CFStringRef)hierarchyKey;
    CFStringRef accessibility = (__bridge CFStringRef)self.itemAccessibility;
    CFDataRef cfData = (__bridge CFDataRef)object;
    object ? rg_set_data_for_key(cfData, cfKey, accessibility) : rg_delete_data_for_key(cfKey);
}

@end
