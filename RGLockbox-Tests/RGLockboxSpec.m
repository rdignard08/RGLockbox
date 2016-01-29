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

@interface RGLockbox (RGForwardDeclarations)

+ (NSMutableDictionary*)valueCache;

@end

static NSString* const kKey1 = @"aKey1";
static NSString* const kKey2 = @"aKey2";
static NSString* testKeys[] = { @"aKey1", @"aKey2" };

CLASS_SPEC(RGLockbox)

- (void) tearDown {
    for (int i = 0; i < 2; i++) {
        [[RGLockbox manager] setData:nil forKey:testKeys[i]];
    }
}

- (void) setUp {
    for (int i = 0; i < 2; i++) {
        [[RGLockbox manager] setData:nil forKey:testKeys[i]];
    }
}


#pragma mark - Reading / Writing / Deleting
- (void) testReadNotExist {
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadNotExistDouble {
    [[RGLockbox manager] dataForKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert(data == nil);
}

- (void) testReadExist {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

- (void) testReadExistDouble {
    [[RGLockbox manager] setData:[NSData new] forKey:kKey1];
    [[RGLockbox manager] dataForKey:kKey1];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    XCTAssert([data isEqual:[NSData new]]);
}

- (void) testReadNotSeen {
    NSString* key = [NSString stringWithFormat:@"%@.%@", [RGLockbox manager].namespace, kKey2];
    [[RGLockbox manager] setData:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey2];
    [[RGLockbox valueCache] removeObjectForKey:key];
    NSData* data = [[RGLockbox manager] dataForKey:kKey2];
    NSLog(@"%@ %@", data, [@"abcd" dataUsingEncoding:NSUTF8StringEncoding]);
    XCTAssert([data isEqual:[@"abcd" dataUsingEncoding:NSUTF8StringEncoding]]);
}

- (void) testReadNoNameSpace {
    RGLockbox* rawAccess = [[RGLockbox alloc] initWithNamespace:nil accessibility:nil];
    [rawAccess setData:[@"abes" dataUsingEncoding:NSUTF8StringEncoding] forKey:@"com.restgoatee.rglockbox.foobar"];
    NSData* data = [rawAccess dataForKey:@"com.restgoatee.rglockbox.foobar"];
    XCTAssert([data isEqual:[@"abes" dataUsingEncoding:NSUTF8StringEncoding]]);
}

#pragma mark - Updating
- (void) testUpdateValue {
    [[RGLockbox manager] setData:[@"abew" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey1];
    [[RGLockbox manager] setData:[@"qwew" dataUsingEncoding:NSUTF8StringEncoding] forKey:kKey1];
    NSString* key = [NSString stringWithFormat:@"%@.%@", [RGLockbox manager].namespace, kKey1];
    [[RGLockbox valueCache] removeObjectForKey:key];
    NSData* data = [[RGLockbox manager] dataForKey:kKey1];
    NSLog(@"%@ %@", data, [@"qwew" dataUsingEncoding:NSUTF8StringEncoding]);
    XCTAssert([data isEqual:[@"qwew" dataUsingEncoding:NSUTF8StringEncoding]]);
}

SPEC_END
