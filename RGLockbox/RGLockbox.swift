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
 block used to retrieve an item from the keychain.  Defaults to `SecItemCopyMatching`.
*/
public var rg_SecItemCopyMatch = { SecItemCopyMatching($0, $1) }

/**
 block used to add a nonexistent item to the keychain.  Defaults to `SecItemAdd`.
*/
public var rg_SecItemAdd = { SecItemAdd($0, $1) }

/**
 block used to update an existing item in the keychain.  Defaults to `SecItemUpdate`.
*/
public var rg_SecItemUpdate = { SecItemUpdate($0, $1) }

/**
 block used to delete an item from the keychain.  Defaults to `SecItemDelete`.
*/
public var rg_SecItemDelete = { SecItemDelete($0) }

/**
 Instances of RGLockbox manage access to a given keychain service name.  The default service is your app's bundle identifier.  A given manager is threadsafe.
*/
public class RGLockbox {

/**
 Keychain accesses are performed on this queue to keep the cache in sync with the backing store.
*/
    public static let keychainQueue = dispatch_queue_create("RGLockbox-Sync", DISPATCH_QUEUE_SERIAL)
    
/**
 This lock controls access to `valueCache`.
*/
    static let valueCacheLock = NSLock()
    
/**
 Your app's bundle identifier pre-calculated.
*/
    public static var bundleIdentifier:String? = NSBundle.mainBundle().infoDictionary?[kCFBundleIdentifierKey as String] as? String
    
/**
 `valueCache` stores in memory the values known to all managers.  A key that has been seen before will used the cached value.
*/
    public static var valueCache:[RGMultiKey : AnyObject] = [:]
    
/**
 Determines the service name used by the manager.
*/
    public let namespace:String?
    
/**
 Determines the accessibility assigned by the manager to a given item on add or update.
*/
    public let itemAccessibility:CFStringRef
    
/**
 Qualifies entries by account if provided.
*/
    public let accountName:String?
    
/**
 Creates a new `RGLockbox` instance with default namespace and item accessibility.
*/
    public class func manager() -> RGLockbox {
        return RGLockbox.init(withNamespace: RGLockbox.bundleIdentifier,
                              accessibility: kSecAttrAccessibleAfterFirstUnlock,
                                accountName: nil)
    }
    
/**
 A new instance of `RGLockbox`.
 - parameter namespace: The service to which the instance is associated.
 - parameter accessibilty: The item accessibility to write to the keychain items.
 - parameter accountName: The manager's associated account if account qualified.
 - returns: An instance of `RGLockbox` with the provided namespace and accessibility.
*/
    public required init(withNamespace namespace:String?, accessibility:CFStringRef, accountName:String?) {
        self.namespace = namespace
        self.itemAccessibility = accessibility
        self.accountName = accountName
    }
    
/**
 Creates a new `RGLockbox` instance with default namespace and item accessibility.
*/
    public convenience init() {
        self.init(withNamespace: RGLockbox.bundleIdentifier,
                  accessibility: kSecAttrAccessibleAfterFirstUnlock,
                    accountName: nil)
    }
    
/**
 Raw read access to the keychain.  Caches reads to `valueCache`.
 - parameter key: The key used to identify the item.
 - returns: `NSData` which is `nil` if not found.
*/
    public func dataForKey(key:String) -> NSData? {
        let fullKey = RGMultiKey()
        fullKey.first = namespace != nil ? "\(namespace!).\(key)" : key
        fullKey.second = self.accountName
        RGLockbox.valueCacheLock.lock()
        let value = RGLockbox.valueCache[fullKey]
        if value != nil {
            RGLockbox.valueCacheLock.unlock()
            RGLogs(RGLogSeverity.Trace, "returning prematurely for key \(key) and value \(value)");
            return value is NSData ? (value as! NSData) : nil
        }
        var data:AnyObject? = nil
        var status:OSStatus = errSecSuccess
        dispatch_sync(RGLockbox.keychainQueue, {
            RGLogs(RGLogSeverity.Trace, "hit sync with key \(key)")
            var query:[NSString:AnyObject] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : fullKey.first!,
                kSecMatchLimit : kSecMatchLimitOne,
                kSecReturnData : true
            ]
            if fullKey.second != nil {
                query[kSecAttrAccount] = fullKey.second!
            }
            status = rg_SecItemCopyMatch(query, &data)
            RGLogs(RGLogSeverity.Trace, "SecItemCopyMatching with \(query) returned \(status)")
        })
        let bridgedData = data as! NSData?
        RGLockbox.valueCache[fullKey] = bridgedData != nil ? bridgedData : NSNull()
        RGLockbox.valueCacheLock.unlock()
        return bridgedData
    }
    
/**
 Raw write access to keychain.  Caches writes to `valueCache`.
 - parameter data: The data to store on the given key.  If `nil` clears the value in the keychain.
 - parameter key: The identifier of the keychain item.
*/
    public func setData(data:NSData?, forKey key:String) {
        let fullKey = RGMultiKey()
        fullKey.first = namespace != nil ? "\(namespace!).\(key)" : key
        fullKey.second = self.accountName
        RGLockbox.valueCacheLock.lock()
        RGLockbox.valueCache[fullKey] = ((data != nil) ? data : NSNull())
        dispatch_async(RGLockbox.keychainQueue, {
            RGLogs(RGLogSeverity.Trace, "key is \(fullKey.first) with data \(data)")
            var status:OSStatus = errSecSuccess
            let query:NSMutableDictionary! = NSMutableDictionary(dictionary:[
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : fullKey.first!
            ])
            if fullKey.second != nil {
                query.setObject(fullKey.second!, forKey: kSecAttrAccount as NSString)
            }
            if let data = data {
                let payload:[NSString:AnyObject] = [
                    kSecValueData : data,
                    kSecAttrAccessible : self.itemAccessibility
                ]
                query.addEntriesFromDictionary(payload)
                status = rg_SecItemAdd(query, nil)
                RGLogs(RGLogSeverity.Trace, "SecItemAdd with \(query) returned \(status)")
                assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
                if status == errSecDuplicateItem {
                    status = rg_SecItemUpdate(query, payload)
                    RGLogs(RGLogSeverity.Trace, "SecItemUpdate with \(query) and \(payload) returned \(status)")
                    assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
                }
                return
            }
            status = rg_SecItemDelete(query)
            RGLogs(RGLogSeverity.Trace, "SecItemDelete with \(query) returned \(status)")
            assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
        })
        RGLockbox.valueCacheLock.unlock()
    }
}
