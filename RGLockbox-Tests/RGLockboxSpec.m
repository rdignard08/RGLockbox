/* Copyright (c) 01/27/2016, Ryan Dignard
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

#import "RGLockbox.h"

static NSString* const kKey1 = @"aKey1";
static NSString* const kKey2 = @"aKey2";
static NSString* testKeys[] = { @"aKey1", @"aKey2" };

CLASS_SPEC(RGLockbox)

- (void) tearDown {
    for (int i = 0; i < sizeof(testKeys) / sizeof(NSString*); i++) {
        [[RGLockbox manager] setObject:nil forKey:testKeys[i]];
    }
}

- (void) setUp {
    for (int i = 0; i < sizeof(testKeys) / sizeof(NSString*); i++) {
        [[RGLockbox manager] setObject:nil forKey:testKeys[i]];
    }
}


#pragma mark - Reading
- (void) testReadNotExist {
    NSData* data = [[RGLockbox manager] objectForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadNotExistDouble {
    [[RGLockbox manager] objectForKey:kKey1];
    NSData* data = [[RGLockbox manager] objectForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadExist {
    [[RGLockbox manager] setObject:[NSData new] forKey:kKey1];
    NSData* data = [[RGLockbox manager] objectForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

- (void) testReadExistDouble {
    [[RGLockbox manager] setObject:[NSData new] forKey:kKey1];
    [[RGLockbox manager] objectForKey:kKey1];
    NSData* data = [[RGLockbox manager] objectForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

SPEC_END
