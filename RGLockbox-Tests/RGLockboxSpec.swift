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
import XCTest
import RGLockbox


let kKey1 = "aKey1"
let kKey2 = "aKey2"
let testKeys = [
    kKey1,
    kKey2
]

class RGLockboxSpec : XCTestCase {
    
    override class func initialize() {
        rg_SecItemCopyMatch = replacementItemCopy
        rg_SecItemAdd = replacementAddItem
        rg_SecItemDelete = replacementDeleteItem
        rg_set_logging_severity(RGLogSeverity.Trace)
    }
    
    override func setUp() {
        RGLockbox.bundleIdentifier = NSBundle(forClass: self.dynamicType).infoDictionary![kCFBundleIdentifierKey as String] as! String?
        for key in testKeys {
            RGLockbox().setData(nil, forKey: key)
        }
        let manager = RGLockbox(withNamespace: nil, accessibility: kSecAttrAccessibleAlways)
        for key in manager.allItems() {
            manager.setData(nil, forKey: key)
        }
        RGLockbox.valueCache.removeAll()
    }
    
    override func tearDown() {
        for key in testKeys {
            RGLockbox().setData(nil, forKey: key)
        }
        let manager = RGLockbox(withNamespace: nil, accessibility: kSecAttrAccessibleAlways)
        for key in manager.allItems() {
            manager .setData(nil, forKey: key)
        }
        RGLockbox.valueCache.removeAll()
    }
    
// MARK: - Reading / Writing / Deleting
    func testReadNotExist() {
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == nil)
    }
    
    func testReadNotExistDouble() {
        RGLockbox().dataForKey(kKey1)
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == nil)
    }
    
    func testReadExist() {
        RGLockbox().setData(NSData(), forKey: kKey1)
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == NSData())
    }
    
    func testReadExistDouble() {
        RGLockbox().setData(NSData(), forKey: kKey1)
        RGLockbox().dataForKey(kKey1)
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == NSData())
    }
    
    func testReadNotSeen() {
        let fullKey = RGMultiKey()
        fullKey.first = "\(RGLockbox().namespace!).\(kKey2)"
        let data = "abcd".dataUsingEncoding(NSUTF8StringEncoding)
        RGLockbox().setData(data, forKey: kKey2)
        RGLockbox.valueCache[fullKey] = nil
        let readData = RGLockbox().dataForKey(kKey2)
        XCTAssert(readData == data)
    }

    func testReadNoNameSpace() {
        let rawLockbox = RGLockbox(withNamespace: nil)
        let data = "abes".dataUsingEncoding(NSUTF8StringEncoding)!
        rawLockbox.setData(data, forKey: "com.restgoatee.rglockbox.foobar")
        let readData = rawLockbox.dataForKey("com.restgoatee.rglockbox.foobar")
        XCTAssert(readData == data)
    }
    
// MARK: - Updating
    func testUpdateValue() {
        let fullKey = RGMultiKey()
        fullKey.first = "\(RGLockbox().namespace!).\(kKey1)"
        let firstData = "abew".dataUsingEncoding(NSUTF8StringEncoding)!
        let secondData = "qwew".dataUsingEncoding(NSUTF8StringEncoding)!
        RGLockbox().setData(firstData, forKey: kKey1)
        RGLogs(.Debug, "1 \(RGLockbox.valueCache[fullKey])")
        RGLockbox().setData(secondData, forKey: kKey1)
        RGLogs(.Debug, "2 \(RGLockbox.valueCache[fullKey])")
        RGLockbox.valueCache[fullKey] = nil
        RGLogs(.Debug, "3 \(RGLockbox.valueCache[fullKey])")
        let readData = RGLockbox().dataForKey(kKey1)
        RGLogs(.Debug, "4 \(RGLockbox.valueCache[fullKey])")
        XCTAssert(readData == secondData)
    }
    
// MARK: - allItems
    func testAllItemsNamespaced() {
        RGLockbox().setData(NSData(), forKey: kKey1)
        RGLockbox().setData(NSData(), forKey: kKey2)
        var keys = [ kKey1, kKey2 ]
        let items = RGLockbox().allItems()
        for key in items {
            XCTAssert(keys.contains(key))
            keys.removeAtIndex(keys.indexOf(key)!)
        }
        XCTAssert(keys.count == 0)
    }
    
    func testAllItemsNoNamespace() {
        let manager = RGLockbox(withNamespace: nil, accessibility: kSecAttrAccessibleAlways)
        manager.setData(NSData(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey1)")
        manager.setData(NSData(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey2)")
        var keys = [ "\(RGLockbox.bundleIdentifier!).\(kKey1)", "\(RGLockbox.bundleIdentifier!).\(kKey2)" ]
        let items = manager.allItems()
        for item in items {
            XCTAssert(keys.contains(item))
            keys.removeAtIndex(keys.indexOf(item)!)
        }
        XCTAssert(keys.count == 0)
    }
    
    func testAllItemsWithAccount() {
        let manager = RGLockbox(withNamespace: nil,
                                accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox")
        RGLockbox().setData(NSData(), forKey: "abcd")
        manager.setData(NSData(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey1)")
        manager.setData(NSData(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey2)")
        var keys = [ "\(RGLockbox.bundleIdentifier!).\(kKey1)", "\(RGLockbox.bundleIdentifier!).\(kKey2)" ]
        let items = manager.allItems()
        for item in items {
            XCTAssert(keys.contains(item))
            keys.removeAtIndex(keys.indexOf(item)!)
        }
        XCTAssert(keys.count == 0)
    }
    
// MARK: - isSynchronized
    func testReadWriteIsSynchronized() {
        let manager = RGLockbox(accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox",
                                synchronized: true)
        manager.setData(NSData(), forKey: kKey2)
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        let value = manager.dataForKey(kKey2)
        XCTAssert(value == NSData())
    }
    
    func testAllItemsSynchronized() {
        let manager = RGLockbox(accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox",
                                synchronized: true)
        RGLockbox().setData(NSData(), forKey: "abcd")
        manager.setData("abew".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        RGLockbox().setData(NSData(), forKey: kKey2)
        let items = manager.allItems()
        XCTAssert(items.first == kKey1)
        XCTAssert(items.count == 1)
    }
    
    func testMakeItemSynchronized() {
        let nonSyncManager = RGLockbox()
        let syncManager = RGLockbox(accessibility: kSecAttrAccessibleAlways, synchronized: true)
        nonSyncManager.setData("abew".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        var value = nonSyncManager.dataForKey(kKey1)
        XCTAssert(value == "abew".dataUsingEncoding(NSUTF8StringEncoding))
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        syncManager.setData("abcd".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        value = syncManager.dataForKey(kKey1)
        XCTAssert(value == "abcd".dataUsingEncoding(NSUTF8StringEncoding))
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        value = nonSyncManager.dataForKey(kKey1)
        XCTAssert(value == "abcd".dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    func testMakeItemNotSynchronized() {
        let nonSyncManager = RGLockbox()
        let syncManager = RGLockbox(accessibility: kSecAttrAccessibleAlways, synchronized: true)
        syncManager.setData("qwas".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey2)
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        var value = nonSyncManager.dataForKey(kKey2)
        XCTAssert(value == "qwas".dataUsingEncoding(NSUTF8StringEncoding))
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        nonSyncManager.setData("abcd".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey2)
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        value = nonSyncManager.dataForKey(kKey2)
        XCTAssert(value == "abcd".dataUsingEncoding(NSUTF8StringEncoding))
        dispatch_sync(RGLockbox.keychainQueue, {})
        RGLockbox.valueCache.removeAll()
        value = syncManager.dataForKey(kKey2)
        XCTAssert(value == "abcd".dataUsingEncoding(NSUTF8StringEncoding))
    }
    
    func testFlushResignActive() {
        RGLockbox().setData("abcd".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        RGLockbox().setData("qweq".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        NSNotificationCenter.defaultCenter().postNotificationName(RGApplicationWillResignActive, object: nil)
        let service = "\(RGLockbox.bundleIdentifier!).\(kKey1)"
        let query:[NSString:AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecMatchLimit : kSecMatchLimitOne,
            kSecReturnData : true,
            kSecAttrService : service
        ];
        var data:CFTypeRef? = nil;
        rg_SecItemCopyMatch(query as NSDictionary, &data);
        let bridgedData = data as? NSData
        XCTAssert(bridgedData == "qweq".dataUsingEncoding(NSUTF8StringEncoding));
    }
    
    func testFlushBackground() {
        RGLockbox().setData("abcd".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        RGLockbox().setData("qweq".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        NSNotificationCenter.defaultCenter().postNotificationName(RGApplicationWillBackground, object: nil)
        let service = "\(RGLockbox.bundleIdentifier!).\(kKey1)"
        let query:[NSString:AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecMatchLimit : kSecMatchLimitOne,
            kSecReturnData : true,
            kSecAttrService : service
        ];
        var data:CFTypeRef? = nil;
        rg_SecItemCopyMatch(query as NSDictionary, &data);
        let bridgedData = data as? NSData
        XCTAssert(bridgedData == "qweq".dataUsingEncoding(NSUTF8StringEncoding));
    }
    
    func testFlushTerminate() {
        RGLockbox().setData("abcd".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        RGLockbox().setData("qweq".dataUsingEncoding(NSUTF8StringEncoding), forKey: kKey1)
        NSNotificationCenter.defaultCenter().postNotificationName(RGApplicationWillTerminate, object: nil)
        let service = "\(RGLockbox.bundleIdentifier!).\(kKey1)"
        let query:[NSString:AnyObject] = [
            kSecClass : kSecClassGenericPassword,
            kSecMatchLimit : kSecMatchLimitOne,
            kSecReturnData : true,
            kSecAttrService : service
        ];
        var data:CFTypeRef? = nil;
        rg_SecItemCopyMatch(query as NSDictionary, &data);
        let bridgedData = data as? NSData
        XCTAssert(bridgedData == "qweq".dataUsingEncoding(NSUTF8StringEncoding));
    }
}
