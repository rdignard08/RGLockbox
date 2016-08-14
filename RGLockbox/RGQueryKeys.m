/* Copyright (c) 08/14/2016, Ryan Dignard
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

#import "RGQueryKeys.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wpointer-bool-conversion"
#pragma clang diagnostic ignored "-Wunreachable-code"
NSString* RG_SUFFIX_NONNULL rg_synchronizable_key(void) {
    static dispatch_once_t onceToken;
    static NSString* synchronizableKey;
    dispatch_once(&onceToken, ^{
        if (&kSecAttrSynchronizable) {
            synchronizableKey = (__bridge id)kSecAttrSynchronizable;
        } else {
            synchronizableKey = @"sync";
        }
    });
    return synchronizableKey;
}

NSString* RG_SUFFIX_NONNULL rg_synchronizable_any(void) {
    static dispatch_once_t onceToken;
    static NSString* synchronizableAny;
    dispatch_once(&onceToken, ^{
        if (&kSecAttrSynchronizableAny) {
            synchronizableAny = (__bridge id)kSecAttrSynchronizableAny;
        } else {
            synchronizableAny = @"syna";
        }
    });
    return synchronizableAny;
}

NSString* RG_SUFFIX_NONNULL rg_accessibility_key(void) {
    static dispatch_once_t onceToken;
    static NSString* accessibilityKey;
    dispatch_once(&onceToken, ^{
        if (&kSecAttrAccessible) {
            accessibilityKey = (__bridge id)kSecAttrAccessible;
        } else {
            accessibilityKey = @"pdmn";
        }
    });
    return accessibilityKey;
}

CFStringRef RG_SUFFIX_NONNULL rg_accessibility_default(void) {
    static dispatch_once_t onceToken;
    static CFStringRef accessibilityDefault;
    dispatch_once(&onceToken, ^{
        if (&kSecAttrAccessibleAfterFirstUnlock) {
            accessibilityDefault = kSecAttrAccessibleAfterFirstUnlock;
        } else {
            accessibilityDefault = (__bridge CFStringRef)@"ck";
        }
    });
    return accessibilityDefault;
}

NSString* RG_SUFFIX_NONNULL rg_accessgroup_key(void) {
    static dispatch_once_t onceToken;
    static NSString* accessgroupKey;
    dispatch_once(&onceToken, ^{
        if (&kSecAttrAccessGroup) {
            accessgroupKey = (__bridge id)kSecAttrAccessGroup;
        } else {
            accessgroupKey = @"agrp";
        }
    });
    return accessgroupKey;
}
