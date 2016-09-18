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

/**
 Provides a per-thread `DateFormatter` with `dateFormat` set to parse ISO style strings.
*/
func rg_stored_date_formatter() -> DateFormatter {
    let _sIsoFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    let _sStoreFormatterKey = "rg_stored_date_formatter"
    var formatter = Thread.current.threadDictionary[_sStoreFormatterKey]
    if formatter == nil {
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = _sIsoFormat
        Thread.current.threadDictionary[_sStoreFormatterKey] = dateFormatter
        formatter = dateFormatter
    }
    return formatter as! DateFormatter
}

/**
 Provides additional functionality over the raw data based implementation.  Supports `Date`, `String`, `id<NSCoding>`
*/
extension RGLockbox {
    
/**
- parameter key: Identifer to search for in the manager's service name.
- returns: A JSON equivalent object (`Array` or `Dictionary`) or `nil` (item not found).
*/
    public func JSONObjectForKey(_ key:String) -> Any? {
        let data = self.dataForKey(key)
        if (data != nil) {
            return try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions(rawValue: 0))
        }
        return nil
    }
    
/**
- parameter object: An `Array` or `Dictionary` object that is convertible by `NSJSONSerialization` or `nil`.  `nil` unsets the stored value.
- parameter key: Location in the manager's service to store the resulting data.
*/
    public func setJSONObject(_ object:Any?, key:String) throws {
        let data = object != nil ? try! JSONSerialization.data(withJSONObject: object!, options: JSONSerialization.WritingOptions(rawValue: 0)) : nil as Data?
        self.setData(data, forKey: key)
    }
    
/**
- parameter key: Identifer to search for in the manager's service name.
- returns: A `String` object decoded from UTF-8 or `nil` (item not found).
*/
    public func stringForKey(_ key:String) -> String? {
        let data = self.dataForKey(key)
        return data != nil ? String.init(data: data!, encoding: String.Encoding.utf8) : nil
    }
    
/**
- parameter string: A `String` object that is convertible by to UTF-8. or `nil`.  `nil` unsets the stored value.
- parameter key: Location in the manager's service to store the resulting data.
*/
    public func setString(_ string:String?, key:String) {
        let data = string?.data(using: String.Encoding.utf8)
        self.setData(data, forKey: key)
    }
    
/**
- parameter key: Identifer to search for in the manager's service name.
- returns: A `Date` object decoded based on ISO format or `nil` (item not found or parse failure).
*/
    public func dateForKey(_ key:String) -> Date? {
        let data = self.dataForKey(key)
        if (data != nil) {
            let dateString = String.init(data: data!, encoding: String.Encoding.utf8)
            return rg_stored_date_formatter().date(from: dateString!)
        }
        return nil
    }
    
/**
- parameter date: A `Date` object or `nil`. `nil` unsets the stored value.
- parameter key: Location in the manager's service to store the resulting data.
*/
    public func setDate(_ date:Date?, key:String) {
        let dateString = date != nil ? rg_stored_date_formatter().string(from: date!) : nil as String?
        let data = dateString?.data(using: String.Encoding.utf8)
        self.setData(data, forKey: key)
    }
    
/**
- parameter key: Identifer to search for in the manager's service name.
- returns: An object conforming to `NSCoding` created by `NSKeyedUnarchiver` or `nil` (item not found).
*/
    public func codeableForKey(_ key:String) -> NSCoding? {
        let data = self.dataForKey(key)
        let ret = data != nil ? NSKeyedUnarchiver.unarchiveObject(with: data!) : nil as AnyObject?
        return ret as! NSCoding?
    }
    
/**
- parameter codeable: An object conforming to `NSCoding` or `nil`.  `nil` unsets the stored value.
- parameter key: Location in the manager's service to store the resulting data.
*/
    public func setCodeable(_ codeable:NSCoding?, key:String) {
        let data = codeable != nil ? NSKeyedArchiver.archivedData(withRootObject: codeable!) : nil as Data?
        self.setData(data, forKey: key)
    }

}
