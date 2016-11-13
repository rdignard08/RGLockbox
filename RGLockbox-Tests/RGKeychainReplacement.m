/* Copyright (c) 02/13/2016, Ryan Dignard
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

static NSMutableDictionary* theKeychainLol;
static NSLock* keychainLock;

void initializeKeychain(void) {
    theKeychainLol = [NSMutableDictionary new];
    theKeychainLol[@""] = [NSMutableDictionary new];
    theKeychainLol[@"com.restgoatee.rglockbox"] = [NSMutableDictionary new];
    keychainLock = [NSLock new];
}

OSStatus replacementItemCopy(CFDictionaryRef query, CFTypeRef* value) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSString* account = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrAccount) ?: @"";
    [keychainLock lock];
    if ([(__bridge id)CFDictionaryGetValue(query, kSecMatchLimit) isEqual:(__bridge id)kSecMatchLimitAll]) {
        NSMutableArray* output = [NSMutableArray new];
        for (NSString* localAccount in theKeychainLol) {
            if (!account.length || [localAccount isEqual:account]) {
                NSArray* keys = [(NSDictionary*)theKeychainLol[account] allKeys];
                for (NSString* localKey in keys) {
                    NSDictionary* dict = @{ (__bridge id)kSecAttrService : localKey };
                    if (![output containsObject:dict]) {
                        [output addObject:dict];
                    }
                }
            }
        }
        [keychainLock unlock];
        *value = (__bridge_retained CFTypeRef)output;
        return output.count ? errSecSuccess : errSecItemNotFound;
    }
    id storedValue = theKeychainLol[account][key];
    [keychainLock unlock];
    if (storedValue) {
        *value = (__bridge_retained CFTypeRef)storedValue;
        return errSecSuccess;
    }
    return errSecItemNotFound;
}

OSStatus replacementAddItem(CFDictionaryRef query, CFTypeRef* __unused value) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSString* account = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrAccount) ?: @"";
    NSData* data = (__bridge NSData*)CFDictionaryGetValue(query, kSecValueData);
    [keychainLock lock];
    id storedValue = theKeychainLol[account][key];
    if (!storedValue) {
        theKeychainLol[account][key] = data;
        [keychainLock unlock];
        return errSecSuccess;
    }
    [keychainLock unlock];
    return errSecDuplicateItem;
}

OSStatus replacementDeleteItem(CFDictionaryRef query) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSString* account = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrAccount) ?: @"";
    [keychainLock lock];
    if (key) {
        id value = theKeychainLol[account][key];
        [(NSMutableDictionary*)theKeychainLol[account] removeObjectForKey:key];
        [keychainLock unlock];
        return value ? errSecSuccess : errSecItemNotFound;
    } else {
        NSUInteger count = [(NSDictionary*)theKeychainLol[account] count];
        [theKeychainLol[account] removeAllObjects];
        return count ? errSecSuccess : errSecItemNotFound;
    }
}

OSStatus replacementItemCopyBad(__unused CFDictionaryRef query, CFTypeRef* value) {
    *value = nil;
    return errSecInteractionNotAllowed;
}
