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
    keychainLock = [NSLock new];
}

OSStatus replacementItemCopy(CFDictionaryRef query, CFTypeRef* value) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSNumber* returnData = (__bridge NSNumber*)CFDictionaryGetValue(query, kSecReturnData);
    __block id storedValue;
    [keychainLock lock];
    storedValue = theKeychainLol[key];
    [keychainLock unlock];
    if (storedValue) {
        if (returnData.boolValue) {
            *value = (__bridge_retained CFTypeRef)storedValue;
        }
        return errSecSuccess;
    }
    return errSecItemNotFound;
}

OSStatus replacementAddItem(CFDictionaryRef query, CFTypeRef* __unused value) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSData* data = (__bridge NSData*)CFDictionaryGetValue(query, kSecValueData);
    __block id storedValue;
    [keychainLock lock];
    storedValue = theKeychainLol[key];
    [keychainLock unlock];
    if (!storedValue) {
        [keychainLock lock];
        theKeychainLol[key] = data;
        [keychainLock unlock];
        return errSecSuccess;
    }
    return errSecDuplicateItem;
}

OSStatus replacementUpdateItem(CFDictionaryRef query, CFDictionaryRef attributes) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    NSData* data = (__bridge NSData*)CFDictionaryGetValue(attributes, kSecValueData);
    __block id storedValue;
    [keychainLock lock];
    storedValue = theKeychainLol[key];
    [keychainLock unlock];
    if (storedValue) {
        [keychainLock lock];
        theKeychainLol[key] = data;
        [keychainLock unlock];
        return errSecSuccess;
    }
    return errSecItemNotFound;
}

OSStatus replacementDeleteItem(CFDictionaryRef query) {
    NSString* key = (__bridge NSString*)CFDictionaryGetValue(query, kSecAttrService);
    [keychainLock lock];
    id value = theKeychainLol[key];
    [theKeychainLol removeObjectForKey:key];
    [keychainLock unlock];
    return value ? errSecSuccess : errSecItemNotFound;
}

OSStatus replacementItemCopyBad(__unused CFDictionaryRef query, CFTypeRef* value) {
    *value = nil;
    return errSecInteractionNotAllowed;
}
