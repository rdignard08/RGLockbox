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

#import <Foundation/Foundation.h>

@interface RGLockbox : NSObject

/**
 Returns the singleton instance for managing access to the key chain.  Uses the default namespace.
 */
+ (instancetype) manager;

/**
 Returns an instance of `RGLockbox` which is not default namespaced.
 */
- (instancetype) initWithNamespace:(NSString*)namespace accessibility:(NSString*)accessibility NS_DESIGNATED_INITIALIZER;

/**
 Defaults to the app bundle identifier if unspecified.
 */
@property (nonatomic, strong, readonly) NSString* namespace;

/**
 The default accessibility when checking the keychain, defaults to `kSecAttrAccessibleAfterFirstUnlock`.
 */
@property (nonatomic, strong, readonly) NSString* itemAccessibility;

/**
 Return the object set on key in the current namespace.  Only supports NSData at the moment.
 */
- (NSData*) objectForKey:(NSString*)key;

/**
 Allows `[RGLockbox manager][key] = object` syntax for the above.
 */
- (void) setObject:(NSData*)object forKey:(NSString*)key;

@end
