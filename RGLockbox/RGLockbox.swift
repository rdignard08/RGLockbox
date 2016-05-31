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
import Security

/**
 @brief block used to retrieve an item from the keychain.  Defaults to `SecItemCopyMatching`.
*/
public var rg_SecItemCopyMatch = { SecItemCopyMatching($0, $1) }

/**
 @brief block used to add a nonexistent item to the keychain.  Defaults to `SecItemAdd`.
*/
public var rg_SecItemAdd = { SecItemAdd($0, $1) }

/**
 @brief block used to update an existing item in the keychain.  Defaults to `SecItemUpdate`.
*/
public var rg_SecItemUpdate = { SecItemUpdate($0, $1) }

/**
 @brief block used to delete an item from the keychain.  Defaults to `SecItemDelete`.
*/
public var rg_SecItemDelete = { SecItemDelete($0) }

public class RGLockbox {
    static let keychainQueue = dispatch_queue_create("RGLockbox-Sync", DISPATCH_QUEUE_SERIAL)
    static let valueCacheLock = NSLock()
    public static var bundleIdentifier:String? = NSBundle.mainBundle().infoDictionary?[kCFBundleIdentifierKey as String] as? String
    public static var valueCache:[String : AnyObject] = [:];
    
    public let namespace:String?
    public let itemAccessibility:CFStringRef
    
    public class func manager() -> RGLockbox {
        return RGLockbox.init(withNamespace: RGLockbox.bundleIdentifier, accessibility: kSecAttrAccessibleAfterFirstUnlock)
    }
    
    public required init(withNamespace namespace:String?, accessibility: CFStringRef) {
        self.namespace = namespace
        itemAccessibility = accessibility
    }
    
    public convenience init() {
        self.init(withNamespace: RGLockbox.bundleIdentifier, accessibility: kSecAttrAccessibleAfterFirstUnlock)
    }
    
    public func dataForKey(key:String) -> NSData? {
        let hierarchyKey = namespace != nil ? "\(namespace!).\(key)" : key
        RGLockbox.valueCacheLock.lock()
        let value = RGLockbox.valueCache[hierarchyKey]
        if value != nil {
            RGLockbox.valueCacheLock.unlock()
            NSLog("returning prematurely for key \(key) and value \(value)")
            return value is NSData ? (value as! NSData) : nil
        }
        var data:AnyObject? = nil
        var status:OSStatus = errSecSuccess
        dispatch_sync(RGLockbox.keychainQueue, {
            NSLog("hit sync with key \(key)")
            let query:[NSString:AnyObject] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : hierarchyKey,
                kSecMatchLimit : kSecMatchLimitOne,
                kSecReturnData : true
            ]
            status = rg_SecItemCopyMatch(query, &data)
            NSLog("SecItemCopyMatching with \(query) returned \(status)")
        })
        let bridgedData = data as! NSData?
        RGLockbox.valueCache[hierarchyKey] = bridgedData != nil ? bridgedData : NSNull()
        RGLockbox.valueCacheLock.unlock()
        return bridgedData
    }
    
    public func setData(data:NSData?, forKey key:String) {
        let hierarchyKey = namespace != nil ? "\(namespace!).\(key)" : key
        RGLockbox.valueCacheLock.lock()
        RGLockbox.valueCache[hierarchyKey] = ((data != nil) ? data : NSNull())
        dispatch_async(RGLockbox.keychainQueue, {
            NSLog("key is \(hierarchyKey) with data \(data)")
            var status:OSStatus = errSecSuccess
            let query:NSMutableDictionary! = NSMutableDictionary(dictionary:[
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : hierarchyKey
            ])
            if let data = data {
                let payload:[NSString:AnyObject] = [
                    kSecValueData : data,
                    kSecAttrAccessible : self.itemAccessibility
                ]
                query.addEntriesFromDictionary(payload)
                status = rg_SecItemAdd(query, nil)
                NSLog("SecItemAdd with \(query) returned \(status)")
                assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
                if status == errSecDuplicateItem {
                    status = rg_SecItemUpdate(query, payload)
                    NSLog("SecItemUpdate with \(query) and \(payload) returned \(status)")
                    assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
                }
                return
            }
            status = rg_SecItemDelete(query)
            NSLog("SecItemDelete with \(query) returned \(status)")
            assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
        })
        RGLockbox.valueCacheLock.unlock()
    }
}
