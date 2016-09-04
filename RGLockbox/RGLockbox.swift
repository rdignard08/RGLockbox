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
public var rg_SecItemAdd = { SecItemAdd($0, nil) }

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
    public static let keychainQueue = DispatchQueue(label: "RGLockbox-Sync")
    
/**
 This lock controls access to `valueCache`.
 */
    static let valueCacheLock = NSLock()
    
/**
 Your app's bundle identifier pre-calculated.
 */
    public static var bundleIdentifier:String? = Bundle.main.infoDictionary?[kCFBundleIdentifierKey as String] as? String
    
/**
 `valueCache` stores in memory the values known to all managers.  A key that has been seen before will used the cached value.
 */
    public static var valueCache:[RGMultiKey : Any] = [:]
    
/**
 Determines the service name used by the manager.
 */
    public let namespace:String?
    
/**
 Determines the accessibility assigned by the manager to a given item on add or update.
 */
    public let itemAccessibility:CFString
    
/**
 Qualifies entries by account if provided.
 */
    public let accountName:String?
    
/**
 Qualifies searches and writes to this accessGroup if provided.
 */
    public let accessGroup:String?
    
/**
 Marks items written by this manager to be synchronizable.
 */
    public let isSynchronized:Bool
    
/**
 Creates a new `RGLockbox` instance with default namespace and item accessibility.
 */
    public class func manager() -> RGLockbox {
        return RGLockbox()
    }
    
/**
 A new instance of `RGLockbox`.
 - parameter namespace: The service to which the instance is associated.
 - parameter accessibilty: The item accessibility to write to the keychain items.
 - parameter accountName: The manager's associated account if account qualified.
 - parameter accessGroup: The manager's associated accessGroup if restricted.
 - parameter synchronized: Whether this manager's writes will be marked synchronizable.
 - returns: An instance of `RGLockbox` with the provided namespace and accessibility.
 */
    public required init(withNamespace namespace:String? = RGLockbox.bundleIdentifier,
                                       accessibility:CFString = kSecAttrAccessibleAfterFirstUnlock,
                                       accountName:String? = nil,
                                       accessGroup:String? = nil,
                                       synchronized:Bool = false) {
        self.namespace = namespace
        self.itemAccessibility = accessibility
        self.accountName = accountName
        self.accessGroup = accessGroup
        self.isSynchronized = synchronized
    }
    
/**
 Raw read access to the keychain.  Caches reads to `valueCache`.
 - parameter key: The key used to identify the item.
 - returns: `Data` which is `nil` if not found.
 */
    @discardableResult
    public func dataForKey(_ key:String) -> Data? {
        let fullKey = RGMultiKey()
        fullKey.first = namespace != nil ? "\(namespace!).\(key)" : key
        fullKey.second = self.accountName
        fullKey.third = self.accessGroup
        RGLockbox.valueCacheLock.lock()
        let value = RGLockbox.valueCache[fullKey]
        if value != nil {
            RGLockbox.valueCacheLock.unlock()
            RGLogs(.trace, "returning prematurely for key \(key) and value \(value)")
            return value is Data ? (value as! Data) : nil
        }
        var data:AnyObject? = nil
        RGLockbox.keychainQueue.sync(execute: {
            RGLogs(.trace, "hit sync with key \(key)")
            var query:[NSString:Any] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : fullKey.first!,
                kSecMatchLimit : kSecMatchLimitOne,
                kSecReturnData : true,
                kSecAttrSynchronizable : kSecAttrSynchronizableAny
            ]
            if fullKey.second != nil {
                query[kSecAttrAccount] = fullKey.second!
            }
            if fullKey.third != nil {
                query[kSecAttrAccessGroup] = fullKey.third!
            }
            let status = rg_SecItemCopyMatch(query as NSDictionary, &data)
            RGLogs(.trace, "SecItemCopyMatching with \(query) returned \(status)")
        })
        let bridgedData = data as! Data?
        RGLockbox.valueCache[fullKey] = bridgedData != nil ? bridgedData : NSNull()
        RGLockbox.valueCacheLock.unlock()
        return bridgedData
    }
    
    public func allItems() -> Array<String> {
        let fullKey = RGMultiKey()
        fullKey.second = self.accountName
        fullKey.third = self.accessGroup
        var data:AnyObject? = nil
        RGLockbox.keychainQueue.sync(execute: {
            RGLogs(.trace, "hit sync with fetch all")
            var query:[NSString:Any] = [
                kSecClass : kSecClassGenericPassword,
                kSecMatchLimit : kSecMatchLimitAll,
                kSecReturnAttributes : true,
                kSecAttrSynchronizable : kSecAttrSynchronizableAny
            ]
            if fullKey.second != nil {
                query[kSecAttrAccount] = fullKey.second!
            }
            if fullKey.third != nil {
                query[kSecAttrAccessGroup] = fullKey.third!
            }
            let status = rg_SecItemCopyMatch(query as NSDictionary, &data)
            RGLogs(.trace, "SecItemCopyMatching with \(query) returned \(status)")
        })
        let items = data as? Array<Dictionary<String, AnyObject>>
        var output:Array<String> = []
        for item in items ?? [] {
            let service = item[kSecAttrService as String] as! String
            if self.namespace == nil {
                output.append(service)
            } else if service.hasPrefix("\(self.namespace!).") {
                let range = service.range(of: "\(self.namespace!).")
                output.append(service.substring(from: range!.upperBound))
            }
        }
        return output
    }
    
/**
 Raw write access to keychain.  Caches writes to `valueCache`.
 - parameter data: The data to store on the given key.  If `nil` clears the value in the keychain.
 - parameter key: The identifier of the keychain item.
 */
    public func setData(_ data:Data?, forKey key:String) {
        let fullKey = RGMultiKey()
        fullKey.first = namespace != nil ? "\(namespace!).\(key)" : key
        fullKey.second = self.accountName
        fullKey.third = self.accessGroup
        RGLockbox.valueCacheLock.lock()
        RGLockbox.valueCache[fullKey] = ((data != nil) ? data : NSNull())
        RGLockbox.keychainQueue.async(execute: {
            RGLogs(.trace, "key is \(fullKey.first) with data \(data)")
            var query:[NSString:Any] = [
                kSecClass : kSecClassGenericPassword,
                kSecAttrService : fullKey.first!,
                kSecAttrSynchronizable : kSecAttrSynchronizableAny
            ]
            if fullKey.second != nil {
                query[kSecAttrAccount] = fullKey.second!
            }
            if fullKey.third != nil {
                query[kSecAttrAccessGroup] = fullKey.third!
            }
            var status = rg_SecItemDelete(query as NSDictionary)
            RGLogs(.trace, "SecItemDelete with \(query) returned \(status)")
            assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
            if let data = data {
                query[kSecValueData] = data
                query[kSecAttrAccessible] = self.itemAccessibility
                query[kSecAttrSynchronizable] = self.isSynchronized
                status = rg_SecItemAdd(query as NSDictionary)
                RGLogs(.trace, "SecItemAdd with \(query) returned \(status)")
                assert(status != errSecInteractionNotAllowed, "Keychain item unavailable, change itemAccessibility")
            }
        })
        RGLockbox.valueCacheLock.unlock()
    }
}
