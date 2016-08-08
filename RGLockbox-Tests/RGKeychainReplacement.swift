/* Copyright (c) 02/21/2016, Ryan Dignard
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

import Foundation

var theKeychainLol:Dictionary<String, Data> = [:]
var keychainLock = Lock()

let replacementItemCopy:(CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { query, value in
    let key:String = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecAttrService)), to: CFString.self) as String
    let returnData:NSNumber = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecReturnData)), to: NSNumber.self)
    keychainLock.lock()
    let storedValue = theKeychainLol[key]
    keychainLock.unlock()
    if let storedValue = storedValue {
        if returnData.boolValue {
            value?.pointee = storedValue
        }
        return errSecSuccess
    }
    return errSecItemNotFound
}

let replacementAddItem:(CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { query, value in
    let key:String = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecAttrService)), to: CFString.self) as String
    let data = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecValueData)), to: Data.self)
    keychainLock.lock()
    let storedValue = theKeychainLol[key]
    if let storedValue = storedValue {
        keychainLock.unlock()
        return errSecDuplicateItem
    }
    theKeychainLol[key] = data
    keychainLock.unlock()
    return errSecSuccess
}

let replacementUpdateItem:(CFDictionary, CFDictionary) -> OSStatus = { query, attributes in
    let key:String = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecAttrService)), to: CFString.self) as String
    let data = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecValueData)), to: Data.self)
    keychainLock.lock()
    let storedValue = theKeychainLol[key]
    if let storedValue = storedValue {
        theKeychainLol[key] = data
        keychainLock.unlock()
        return errSecSuccess
    }
    keychainLock.unlock()
    return errSecItemNotFound
}

let replacementDeleteItem:(CFDictionary) -> OSStatus = { query in
    let key:String = unsafeBitCast(CFDictionaryGetValue(query, unsafeAddress(of: kSecAttrService)), to: CFString.self) as String
    keychainLock.lock()
    let value = theKeychainLol[key]
    theKeychainLol[key] = nil
    keychainLock.unlock()
    return (value != nil) ? errSecSuccess : errSecItemNotFound
}
