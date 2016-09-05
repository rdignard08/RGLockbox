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
import RGLockboxIOS


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
        rg_set_logging_severity(.trace)
    }
    
    override func setUp() {
        RGLockbox.bundleIdentifier = Bundle(for: type(of: self)).infoDictionary![kCFBundleIdentifierKey as String] as! String?
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
        RGLockbox().setData(Data(), forKey: kKey1)
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == Data())
    }
    
    func testReadExistDouble() {
        RGLockbox().setData(Data(), forKey: kKey1)
        RGLockbox().dataForKey(kKey1)
        let data = RGLockbox().dataForKey(kKey1)
        XCTAssert(data == Data())
    }
    
    func testReadNotSeen() {
        let fullKey = RGMultiKey(withFirst: "\(RGLockbox().namespace!).\(kKey2)")
        let data = "abcd".data(using: String.Encoding.utf8)
        RGLockbox().setData(data, forKey: kKey2)
        RGLockbox.valueCache[fullKey] = nil
        let readData = RGLockbox().dataForKey(kKey2)
        XCTAssert(readData == data)
    }

    func testReadNoNameSpace() {
        let rawLockbox = RGLockbox(withNamespace: nil)
        let data = "abes".data(using: String.Encoding.utf8)!
        rawLockbox.setData(data, forKey: "com.restgoatee.rglockbox.foobar")
        let readData = rawLockbox.dataForKey("com.restgoatee.rglockbox.foobar")
        XCTAssert(readData == data)
    }
    
// MARK: - Updating
    func testUpdateValue() {
        let fullKey = RGMultiKey(withFirst: "\(RGLockbox().namespace!).\(kKey1)")
        let firstData = "abew".data(using: String.Encoding.utf8)!
        let secondData = "qwew".data(using: String.Encoding.utf8)!
        RGLockbox().setData(firstData, forKey: kKey1)
        RGLockbox().setData(secondData, forKey: kKey1)
        RGLockbox.valueCache[fullKey] = nil
        let readData = RGLockbox().dataForKey(kKey1)
        XCTAssert(readData == secondData)
    }
    
// MARK: - allItems
    func testAllItemsNamespaced() {
        RGLockbox().setData(Data(), forKey: kKey1)
        RGLockbox().setData(Data(), forKey: kKey2)
        var keys = [ kKey1, kKey2 ]
        let items = RGLockbox().allItems()
        for key in items {
            XCTAssert(keys.contains(key))
            keys.remove(at: keys.index(of: key)!)
        }
        XCTAssert(keys.count == 0)
    }
    
    func testAllItemsNoNamespace() {
        let manager = RGLockbox(withNamespace: nil, accessibility: kSecAttrAccessibleAlways)
        manager.setData(Data(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey1)")
        manager.setData(Data(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey2)")
        var keys = [ "\(RGLockbox.bundleIdentifier!).\(kKey1)", "\(RGLockbox.bundleIdentifier!).\(kKey2)" ]
        let items = manager.allItems()
        for item in items {
            XCTAssert(keys.contains(item))
            keys.remove(at: keys.index(of: item)!)
        }
        XCTAssert(keys.count == 0)
    }
    
    func testAllItemsWithAccount() {
        let manager = RGLockbox(withNamespace: nil,
                                accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox")
        RGLockbox().setData(Data(), forKey: "abcd")
        manager.setData(Data(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey1)")
        manager.setData(Data(), forKey: "\(RGLockbox.bundleIdentifier!).\(kKey2)")
        var keys = [ "\(RGLockbox.bundleIdentifier!).\(kKey1)", "\(RGLockbox.bundleIdentifier!).\(kKey2)" ]
        let items = manager.allItems()
        for item in items {
            XCTAssert(keys.contains(item))
            keys.remove(at: keys.index(of: item)!)
        }
        XCTAssert(keys.count == 0)
    }
    
// MARK: - isSynchronized
    func testReadWriteIsSynchronized() {
        let manager = RGLockbox(accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox",
                                synchronized: true)
        manager.setData(Data(), forKey: kKey2)
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        let value = manager.dataForKey(kKey2)
        XCTAssert(value == Data())
    }
    
    func testAllItemsSynchronized() {
        let manager = RGLockbox(accessibility: kSecAttrAccessibleAlways,
                                accountName: "com.restgoatee.rglockbox",
                                synchronized: true)
        RGLockbox().setData(Data(), forKey: "abcd")
        manager.setData("abew".data(using: String.Encoding.utf8), forKey: kKey1)
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        RGLockbox().setData(Data(), forKey: kKey2)
        let items = manager.allItems()
        XCTAssert(items.first == kKey1)
        XCTAssert(items.count == 1)
    }
    
    func testMakeItemSynchronized() {
        let nonSyncManager = RGLockbox()
        let syncManager = RGLockbox(accessibility: kSecAttrAccessibleAlways, synchronized: true)
        nonSyncManager.setData("abew".data(using: String.Encoding.utf8), forKey: kKey1)
        var value = nonSyncManager.dataForKey(kKey1)
        XCTAssert(value == "abew".data(using: String.Encoding.utf8))
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        syncManager.setData("abcd".data(using: String.Encoding.utf8), forKey: kKey1)
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        value = syncManager.dataForKey(kKey1)
        XCTAssert(value == "abcd".data(using: String.Encoding.utf8))
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        value = nonSyncManager.dataForKey(kKey1)
        XCTAssert(value == "abcd".data(using: String.Encoding.utf8))
    }
    
    func testMakeItemNotSynchronized() {
        let nonSyncManager = RGLockbox()
        let syncManager = RGLockbox(accessibility: kSecAttrAccessibleAlways, synchronized: true)
        syncManager.setData("qwas".data(using: String.Encoding.utf8), forKey: kKey2)
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        var value = nonSyncManager.dataForKey(kKey2)
        XCTAssert(value == "qwas".data(using: String.Encoding.utf8))
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        nonSyncManager.setData("abcd".data(using: String.Encoding.utf8), forKey: kKey2)
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        value = nonSyncManager.dataForKey(kKey2)
        XCTAssert(value == "abcd".data(using: String.Encoding.utf8))
        RGLockbox.keychainQueue.sync {}
        RGLockbox.valueCache.removeAll()
        value = syncManager.dataForKey(kKey2)
        XCTAssert(value == "abcd".data(using: String.Encoding.utf8))
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
