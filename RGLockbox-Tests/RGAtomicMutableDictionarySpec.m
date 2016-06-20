/* Copyright (c) 06/20/2016, Ryan Dignard
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

#import <XCTest/XCTest.h>
#import "RGAtomicMutableDictionary.h"

CLASS_SPEC(RGAtomicMutableDictionary)

- (void) testAssignAndRetreive {
    RGAtomicMutableDictionary* container = [RGAtomicMutableDictionary new];
    container[@"aKey"] = @"aValue";
    id value = container[@"aKey"];
    XCTAssert([value isEqual:@"aValue"]);
    
    RGAtomicMutableDictionary* container2 = [[RGAtomicMutableDictionary alloc] initWithCapacity:4];
    container2[@"aKey2"] = @"aValue2";
    XCTAssert([container2[@"aKey2"] isEqual:@"aValue2"]);
    
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:container2];
    NSMutableDictionary* restored = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    restored[@"aKey3"] = @"aValue3";
    id value3 = restored[@"aKey3"];
    id value2 = restored[@"aKey2"];
    XCTAssert([value3 isEqual:@"aValue3"]);
    XCTAssert([value2 isEqual:@"aValue2"]);
    
    [container2 removeObjectForKey:@"aKey2"];
    XCTAssert(container2[@"aKey2"] == nil);
    
    id objs[] = { @"aValue4" };
    id keys[] = { @"aKey4" };
    RGAtomicMutableDictionary* oneMore = [[RGAtomicMutableDictionary alloc] initWithObjects:objs forKeys:keys count:1];
    XCTAssert([oneMore[@"aKey4"] isEqual:@"aValue4"]);
}

SPEC_END
