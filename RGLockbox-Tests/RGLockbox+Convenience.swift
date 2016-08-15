//
//  RGLockbox+Convenience.swift
//  RGLockbox
//
//  Created by Ryan Dignard on 5/31/16.
//  Copyright © 2016 Ryan Dignard. All rights reserved.
//

import Foundation
import XCTest
import RGLockboxIOS

let kTestKey = "testKey"

class RGLockbox_ConvenienceSpec : XCTestCase {
    
    override func setUp() {
        RGLockbox.manager().setData(nil, forKey: kTestKey)
        RGLockbox.valueCache.removeAll()
    }
    
    override func tearDown() {
        RGLockbox.manager().setData(nil, forKey: kTestKey)
        RGLockbox.valueCache.removeAll()
    }

    func testGetJSONNil() {
        let value = RGLockbox.manager().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetJSONNotNil() {
        try! RGLockbox.manager().setJSONObject([ "foobar" : "baz" ], key: kTestKey)
        let value = RGLockbox.manager().JSONObjectForKey(kTestKey)
        XCTAssert(value as! Dictionary == [ "foobar" : "baz" ])
    }
    
    func testGetJSONBad() {
        RGLockbox.manager().setCodeable(URL.init(string: "google.com"), key: kTestKey)
        let value = RGLockbox.manager().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testSetJSONNil() {
        try! RGLockbox.manager().setJSONObject(nil, key: kTestKey)
        let value = RGLockbox.manager().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testSetJSONNotNil() {
        try! RGLockbox.manager().setJSONObject([ "foo" : "bar" ], key: kTestKey)
        let value = RGLockbox.manager().JSONObjectForKey(kTestKey)
        XCTAssert(value as! Dictionary == [ "foo" : "bar" ])
    }
    
//    func testSetJSONBad() { // TODO: swift ...
//        var failure = false
//        defer {
//            XCTAssert(failure == false)
//        }
//        do {
//            try RGLockbox.manager().setJSONObject(NSURL.init(string: "google.com"), key: kTestKey)
//            failure = true
//        }
//        catch {
//            
//        }
//    }

    func testGetDateNil() {
        RGLockbox.manager().setDate(nil, key: kTestKey)
        let value = RGLockbox.manager().dateForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetDateNotNil() {
        let date = Date.init()
        RGLockbox.manager().setDate(date, key: kTestKey)
        let value = RGLockbox.manager().dateForKey(kTestKey)
        XCTAssert(value!.timeIntervalSince1970 == floor(date.timeIntervalSince1970))
    }
    
    func testGetDateBad() {
        RGLockbox.manager().setString("abcd", key: kTestKey)
        let value = RGLockbox.manager().dateForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetStringNil() {
        let value = RGLockbox.manager().stringForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetStringNotNil() {
        RGLockbox.manager().setString("abcd", key: kTestKey)
        let value = RGLockbox.manager().stringForKey(kTestKey)
        XCTAssert(value == "abcd")
    }
    
    func testGetCodeableNil() {
        RGLockbox.manager().setCodeable(nil, key: kTestKey)
        let value = RGLockbox.manager().codeableForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetCodeableNotNil() {
        RGLockbox.manager().setCodeable(URL.init(string: "google.com"), key: kTestKey)
        let value = RGLockbox.manager().codeableForKey(kTestKey)
        XCTAssert((value as! NSURL) == URL.init(string: "google.com"))
    }
    
}
