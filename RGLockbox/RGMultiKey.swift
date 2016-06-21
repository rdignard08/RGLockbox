/* Copyright (c) 06/21/2016, Ryan Dignard
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
 `RGMultiKey` is meant to represent a set of keys for use with `NSDictionary`.  Can represent null too.
  Technically this is only a `Pair<NSString*, NSString*>`, but it could be expanded.
*/
public final class RGMultiKey: NSObject, NSCopying {

/**
@brief The first string component of the key.
*/
    public var first:String?

/**
@brief The second string component of the key.  When reversed will not necessarily result in the same hash value.
*/
    public var second:String?
    
    override public func isEqual(object: AnyObject?) -> Bool {
        if let object = object as? RGMultiKey {
            return self.first == object.first && self.second == object.second
        }
        return false
    }
    
    override public var hash: Int {
        let firstHash = self.first == nil ? 0 : self.first!.hash
        let secondHash = self.second == nil ? 0 : self.second!.hash
        return firstHash ^ secondHash
    }
    
    public func copyWithZone(zone: NSZone) -> AnyObject {
        let copy = RGMultiKey.init()
        copy.first = self.first
        copy.second = self.second
        return copy
    }

}

func == (lhs: RGMultiKey?, rhs: RGMultiKey?) -> Bool {
    if lhs == nil && rhs == nil {
        return true
    } else if lhs != nil {
        return lhs!.isEqual(rhs)
    }
    return false
}
