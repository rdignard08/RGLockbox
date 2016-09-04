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
import RGLockboxIOS

var theKeychainLol:Dictionary<RGMultiKey, NSData> = [:]
var keychainLock = NSLock()

let replacementItemCopy:(CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = { query, value in
    let pointer = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrService).toOpaque())
    if pointer != nil {
        let multiKey = RGMultiKey()
        multiKey.first = unsafeBitCast(pointer, to: CFString.self) as String
        let account = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrAccount).toOpaque())
        if account != nil {
            multiKey.second = unsafeBitCast(account, to: CFString.self) as String
        }
        let returnData:NSNumber = unsafeBitCast(CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecReturnData).toOpaque()), to: NSNumber.self)
        keychainLock.lock()
        let storedValue = theKeychainLol[multiKey]
        keychainLock.unlock()
        if let storedValue = storedValue {
            if returnData.boolValue {
                value!.pointee = storedValue
            }
            return errSecSuccess
        }
    } else {
        keychainLock.lock()
        let account = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrAccount).toOpaque())
        var output:[Dictionary<String, String>] = []
        for item in theKeychainLol {
            let key = item.0
            if account != nil {
                let accountName = unsafeBitCast(account, to: CFString.self) as String
                if accountName == key.second {
                    output.append([ kSecAttrService as String : key.first! ])
                }
            } else {
                output.append([ kSecAttrService as String : key.first! ])
            }
        }
        keychainLock.unlock()
        value!.pointee = output as AnyObject?
        return output.count > 0 ? errSecSuccess : errSecItemNotFound
    }

    return errSecItemNotFound
}

let replacementAddItem:(CFDictionary) -> OSStatus = { query in
    let pointer = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrService).toOpaque())
    let multiKey = RGMultiKey()
    multiKey.first = unsafeBitCast(pointer, to: CFString.self) as String
    let account = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrAccount).toOpaque())
    if account != nil {
        multiKey.second = unsafeBitCast(account, to: CFString.self) as String
    }
    let data = unsafeBitCast(CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecReturnData).toOpaque()), to: NSData.self)
    keychainLock.lock()
    let storedValue = theKeychainLol[multiKey]
    if let storedValue = storedValue {
        keychainLock.unlock()
        return errSecDuplicateItem
    }
    theKeychainLol[multiKey] = data
    keychainLock.unlock()
    return errSecSuccess
}

let replacementDeleteItem:(CFDictionary) -> OSStatus = { query in
    let pointer = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrService).toOpaque())
    let multiKey = RGMultiKey()
    multiKey.first = unsafeBitCast(pointer, to: CFString.self) as String
    let account = CFDictionaryGetValue(query, Unmanaged.passUnretained(kSecAttrAccount).toOpaque())
    if account != nil {
        multiKey.second = unsafeBitCast(account, to: CFString.self) as String
    }
    keychainLock.lock()
    let value = theKeychainLol[multiKey]
    theKeychainLol[multiKey] = nil
    keychainLock.unlock()
    return (value != nil) ? errSecSuccess : errSecItemNotFound
}
