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
        rg_SecItemUpdate = replacementUpdateItem
        rg_SecItemDelete = replacementDeleteItem
    }
    
    override func setUp() {
        RGLockbox.bundleIdentifier = NSBundle(forClass: self.dynamicType).infoDictionary![kCFBundleIdentifierKey as String] as! String?
        for key in testKeys {
            RGLockbox.manager().setData(nil, forKey: key)
        }
        RGLockbox.valueCache.removeAll()
    }
    
    override func tearDown() {
        for key in testKeys {
            RGLockbox.manager().setData(nil, forKey: key)
        }
        RGLockbox.valueCache.removeAll()
    }
    
// MARK: - Reading / Writing / Deleting
    func testReadNotExist() {
        let data = RGLockbox.manager().dataForKey(kKey1)
        XCTAssert(data == nil)
    }
    
    func testReadNotExistDouble() {
        RGLockbox.manager().dataForKey(kKey1)
        let data = RGLockbox.manager().dataForKey(kKey1)
        XCTAssert(data == nil)
    }
    
    func testReadExist() {
        RGLockbox.manager().setData(NSData(), forKey: kKey1)
        let data = RGLockbox.manager().dataForKey(kKey1)
        XCTAssert(data == NSData())
    }
    
    func testReadExistDouble() {
        RGLockbox.manager().setData(NSData(), forKey: kKey1)
        RGLockbox.manager().dataForKey(kKey1)
        let data = RGLockbox.manager().dataForKey(kKey1)
        XCTAssert(data == NSData())
    }
    
    func testReadNotSeen() {
        let fullKey = RGMultiKey()
        fullKey.first = "\(RGLockbox.manager().namespace).\(kKey2)"
        let data = "abcd".dataUsingEncoding(NSUTF8StringEncoding)
        RGLockbox.manager().setData(data, forKey: kKey2)
        RGLockbox.valueCache[fullKey] = nil
        let readData = RGLockbox.manager().dataForKey(kKey2)
        XCTAssert(readData == data)
    }

    func testReadNoNameSpace() {
        let rawLockbox = RGLockbox.init(withNamespace: nil, accessibility: kSecAttrAccessibleAfterFirstUnlock, accountName: nil)
        let data = "abes".dataUsingEncoding(NSUTF8StringEncoding)!
        rawLockbox.setData(data, forKey: "com.restgoatee.rglockbox.foobar")
        let readData = rawLockbox.dataForKey("com.restgoatee.rglockbox.foobar")
        XCTAssert(readData == data)
    }
    
// MARK: - Updating
    func testUpdateValue() {
        let fullKey = RGMultiKey()
        fullKey.first = "\(RGLockbox.manager().namespace!).\(kKey1)"
        let firstData = "abew".dataUsingEncoding(NSUTF8StringEncoding)!
        let secondData = "qwew".dataUsingEncoding(NSUTF8StringEncoding)!
        RGLockbox.manager().setData(firstData, forKey: kKey1)
        NSLog("1 \(RGLockbox.valueCache[fullKey])")
        RGLockbox.manager().setData(secondData, forKey: kKey1)
        NSLog("2 \(RGLockbox.valueCache[fullKey])")
        RGLockbox.valueCache[fullKey] = nil
        NSLog("3 \(RGLockbox.valueCache[fullKey])")
        let readData = RGLockbox.manager().dataForKey(kKey1)
        NSLog("4 \(RGLockbox.valueCache[fullKey])")
        XCTAssert(readData == secondData)
    }
}
