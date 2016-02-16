
import Foundation
import XCTest
import RGLockbox


let kKey1 = "aKey1";
let kKey2 = "aKey2";
let testKeys = [
    kKey1,
    kKey2
]

//    + (void) load {
//    initializeKeychain();
//    rg_SecItemCopyMatch = &replacementItemCopy;
//    rg_SecItemAdd = &replacementAddItem;
//    rg_SecItemUpdate = &replacementUpdateItem;
//    rg_SecItemDelete = &replacementDeleteItem;
//    }
//
//

class RGLockboxSpec : XCTestCase {
    
    override func setUp() {
        RGLockbox.bundleIdentifier = NSBundle(forClass: self.dynamicType).infoDictionary![kCFBundleIdentifierKey as String] as! String?
        for key in testKeys {
            RGLockbox.manager().setData(nil, forKey: key);
        }
    }
    
    override func tearDown() {
        for key in testKeys {
            RGLockbox.manager().setData(nil, forKey: key);
        }
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
        let key = "\(RGLockbox.manager().namespace).\(kKey2)"
        let data = "abcd".dataUsingEncoding(NSUTF8StringEncoding)
        RGLockbox.manager().setData(data, forKey: kKey2)
        RGLockbox.valueCache[key] = nil
        let readData = RGLockbox.manager().dataForKey(kKey2)
        XCTAssert(readData == data)
    }

    func testReadNoNameSpace() {
        let rawLockbox = RGLockbox.init(withNamespace: nil, accessibility: kSecAttrAccessibleAfterFirstUnlock)
        let data = "abes".dataUsingEncoding(NSUTF8StringEncoding)!
        rawLockbox.setData(data, forKey: "com.restgoatee.rglockbox.foobar")
        let readData = rawLockbox.dataForKey("com.restgoatee.rglockbox.foobar")
        XCTAssert(readData == data)
    }
    
// MARK: - Updating
    func testUpdateValue() {
        let key = "\(RGLockbox.manager().namespace!).\(kKey1)"
        let firstData = "abew".dataUsingEncoding(NSUTF8StringEncoding)!
        let secondData = "qwew".dataUsingEncoding(NSUTF8StringEncoding)!
        RGLockbox.manager().setData(firstData, forKey: kKey1)
        NSLog("1 \(RGLockbox.valueCache[key])")
        RGLockbox.manager().setData(secondData, forKey: kKey1)
        NSLog("2 \(RGLockbox.valueCache[key])")
        RGLockbox.valueCache[key] = nil
        NSLog("3 \(RGLockbox.valueCache[key])")
        let readData = RGLockbox.manager().dataForKey(kKey1)
        NSLog("4 \(RGLockbox.valueCache[key])")
        XCTAssert(readData == secondData)
    }
}
