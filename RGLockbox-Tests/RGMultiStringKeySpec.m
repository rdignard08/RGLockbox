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

#import "RGMultiStringKey.h"

CLASS_SPEC(RGMultiStringKey)

#pragma mark - isEqual:
- (void) testIsEqualNils {
    RGMultiStringKey* key1 = [RGMultiStringKey new];
    RGMultiStringKey* key2 = [RGMultiStringKey new];
    XCTAssert([key1 isEqual:key2]);
    XCTAssert([key1 hash] == [key2 hash]);
}

- (void) testBothUsedAndEqual {
    RGMultiStringKey* key1 = [RGMultiStringKey new];
    key1.first = @"abcd";
    key1.second = @"qwe";
    RGMultiStringKey* key2 = [RGMultiStringKey new];
    key2.first = @"abcd";
    key2.second = @"qwe";
    XCTAssert([key1 isEqual:key2]);
    XCTAssert([key1 hash] == [key2 hash]);
}

- (void) testDescription {
    RGMultiStringKey* key = [RGMultiStringKey new];
    key.first = @"abcd";
    key.second = @"aString";
    XCTAssert([key.description containsString:RG_STRING_SEL(first)]);
    XCTAssert([key.description containsString:(NSString*)key.first]);
    XCTAssert([key.description containsString:RG_STRING_SEL(second)]);
    XCTAssert([key.description containsString:(NSString*)key.second]);
}

SPEC_END
