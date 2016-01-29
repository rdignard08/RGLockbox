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
#import "RGDefines.h"

@interface RGLockbox : NSObject

/**
 Defaults to this class's bundle identifier.
 */
@property RG_NONNULL_PROPERTY(nonatomic, strong, readonly) NSString* namespace;

/**
 The default accessibility when checking the keychain, defaults to `kSecAttrAccessibleAfterFirstUnlock`.
 */
@property RG_NONNULL_PROPERTY(nonatomic, assign, readonly) CFStringRef itemAccessibility;

/**
 Returns the singleton instance for managing access to the key chain.  Uses the default namespace.
 */
+ (RG_PREFIX_NONNULL instancetype) manager;

/**
 This is the queue on which all keychain accesses are performed.  You do not need to use this to synchronize operations, rather for program correctness you should `dispatch_barrier_sync()` on this queue when your program is about to become inactive.
 */
+ (RG_PREFIX_NONNULL dispatch_queue_t) keychainQueue;

/**
 Returns an instance of `RGLockbox` which has the provided namespace and default accessibility.
 */
- (RG_PREFIX_NONNULL instancetype) initWithNamespace:(RG_PREFIX_NULLABLE NSString*)namespace accessibility:(RG_PREFIX_NULLABLE CFStringRef)accessibility NS_DESIGNATED_INITIALIZER;

/**
 Primitive method to return the data on `key`.
 */
- (RG_PREFIX_NULLABLE NSData*) objectForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 Primitive method to set the data on `key` with the current `itemAccessibility`.
 */
- (BOOL) setObject:(RG_PREFIX_NULLABLE NSData*)data forKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 Primitive method to set the data on `key` with the provided accessibility.
 */
- (BOOL) setObject:(RG_PREFIX_NULLABLE NSData*)data forKey:(RG_PREFIX_NONNULL NSString*)key withAccessibility:(RG_PREFIX_NONNULL CFStringRef)accessibility;

@end
