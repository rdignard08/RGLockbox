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

func rg_stored_date_formatter() -> NSDateFormatter {
    let _sIsoFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    let _sStoreFormatterKey = "rg_stored_date_formatter"
    var formatter = NSThread.currentThread().threadDictionary[_sStoreFormatterKey]
    if formatter == nil {
        let dateFormatter = NSDateFormatter.init()
        dateFormatter.dateFormat = _sIsoFormat
        NSThread.currentThread().threadDictionary[_sStoreFormatterKey] = dateFormatter
        formatter = dateFormatter
    }
    return formatter as! NSDateFormatter
}

extension RGLockbox {
    
    public func JSONObjectForKey(key:String) -> AnyObject? {
        let data = self.dataForKey(key)
        return data != nil ? try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions(rawValue: 0)) : nil
    }
    
    public func setJSONObject(object:AnyObject?, key:String) {
        let data = object != nil ? try! NSJSONSerialization.dataWithJSONObject(object!, options: NSJSONWritingOptions(rawValue: 0)) : nil as NSData?
        self.setData(data, forKey: key)
    }
    
    public func stringForKey(key:String) -> String? {
        let data = self.dataForKey(key)
        return data != nil ? String.init(data: data!, encoding: NSUTF8StringEncoding) : nil
    }
    
    public func setString(string:String?, key:String) {
        let data = string?.dataUsingEncoding(NSUTF8StringEncoding)
        self.setData(data, forKey: key)
    }
    
    public func dateForKey(key:String) -> NSDate? {
        let data = self.dataForKey(key)
        if (data != nil) {
            let dateString = String.init(data: data!, encoding: NSUTF8StringEncoding)
            return rg_stored_date_formatter().dateFromString(dateString!)
        }
        return nil
    }
    
    public func setDate(date:NSDate?, key:String) {
        let dateString = date != nil ? rg_stored_date_formatter().stringFromDate(date!) : nil as String?
        let data = dateString?.dataUsingEncoding(NSUTF8StringEncoding)
        self.setData(data, forKey: key)
    }
    
    public func codeableForKey(key:String) -> NSCoding? {
        let data = self.dataForKey(key)
        let ret = data != nil ? NSKeyedUnarchiver.unarchiveObjectWithData(data!) : nil as AnyObject?
        return ret as! NSCoding?
    }
    
    public func setCodeable(codeable:NSCoding?, key:String) {
        let data = codeable != nil ? NSKeyedArchiver.archivedDataWithRootObject(codeable!) : nil as NSData?
        self.setData(data, forKey: key)
    }

}
