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
        RGLockbox().setData(nil, forKey: kTestKey)
        RGLockbox.valueCache.removeAll()
    }
    
    override func tearDown() {
        RGLockbox().setData(nil, forKey: kTestKey)
        RGLockbox.valueCache.removeAll()
    }

    func testGetJSONNil() {
        let value = RGLockbox().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetJSONNotNil() {
        try! RGLockbox().setJSONObject([ "foobar" : "baz" ], key: kTestKey)
        let value = RGLockbox().JSONObjectForKey(kTestKey)
        XCTAssert(value as! Dictionary == [ "foobar" : "baz" ])
    }
    
    func testGetJSONBad() {
        RGLockbox().setCodeable(URL.init(string: "google.com") as NSCoding?, key: kTestKey)
        let value = RGLockbox().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testSetJSONNil() {
        try! RGLockbox().setJSONObject(nil, key: kTestKey)
        let value = RGLockbox().JSONObjectForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testSetJSONNotNil() {
        try! RGLockbox().setJSONObject([ "foo" : "bar" ], key: kTestKey)
        let value = RGLockbox().JSONObjectForKey(kTestKey)
        XCTAssert(value as! Dictionary == [ "foo" : "bar" ])
    }
    
    func testGetDateNil() {
        RGLockbox().setDate(nil, key: kTestKey)
        let value = RGLockbox().dateForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetDateNotNil() {
        let date = Date.init()
        RGLockbox().setDate(date, key: kTestKey)
        let value = RGLockbox().dateForKey(kTestKey)
        XCTAssert(value!.timeIntervalSince1970 == floor(date.timeIntervalSince1970))
    }
    
    func testGetDateBad() {
        RGLockbox().setString("abcd", key: kTestKey)
        let value = RGLockbox().dateForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetStringNil() {
        let value = RGLockbox().stringForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetStringNotNil() {
        RGLockbox().setString("abcd", key: kTestKey)
        let value = RGLockbox().stringForKey(kTestKey)
        XCTAssert(value == "abcd")
    }
    
    func testGetCodeableNil() {
        RGLockbox().setCodeable(nil, key: kTestKey)
        let value = RGLockbox().codeableForKey(kTestKey)
        XCTAssert(value == nil)
    }
    
    func testGetCodeableNotNil() {
        RGLockbox().setCodeable(URL.init(string: "google.com") as NSCoding?, key: kTestKey)
        let value = RGLockbox().codeableForKey(kTestKey)
        XCTAssert(value as! NSURL? == URL.init(string: "google.com") as NSURL?)
    }
    
}
