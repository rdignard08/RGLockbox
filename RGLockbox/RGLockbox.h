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

#import "RGDefines.h"
#import "RGLog.h"

/**
 @brief Use this function to get the default namespace if you create your own `RGLockbox` but only wish to change the
   `itemAccessibility`.
 */
extern NSString* RG_SUFFIX_NONNULL (* RG_SUFFIX_NONNULL rg_bundle_identifier)(void);

/**
 @brief C function used to retrieve an item from the keychain.  Defaults to `SecItemCopyMatching`.
 */
extern OSStatus (* RG_SUFFIX_NONNULL rg_SecItemCopyMatch)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                          CFTypeRef RG_SUFFIX_NULLABLE * RG_SUFFIX_NULLABLE);

/**
 @brief C function used to add a nonexistent item to the keychain.  Defaults to `SecItemAdd`.
 */
extern OSStatus (* RG_SUFFIX_NONNULL rg_SecItemAdd)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                    CFTypeRef RG_SUFFIX_NULLABLE * RG_SUFFIX_NULLABLE);

/**
 @brief C function used to update an existing item in the keychain.  Defaults to `SecItemUpdate`.
 */
extern OSStatus (* RG_SUFFIX_NONNULL rg_SecItemUpdate)(CFDictionaryRef RG_SUFFIX_NONNULL,
                                                       CFDictionaryRef RG_SUFFIX_NONNULL);

/**
 @brief C function used to delete an item from the keychain.  Defaults to `SecItemDelete`.
 */
extern OSStatus (* RG_SUFFIX_NONNULL rg_SecItemDelete)(CFDictionaryRef RG_SUFFIX_NONNULL);

/**
 @brief `RGLockbox` is a keychain manager class.  It provides the rudimentary actions get, add, update, delete on
   `NSData` instances.  The class is threadsafe and may be read from and written to on multiple threads simultaneously.
 */
@interface RGLockbox : NSObject

/**
 @brief Defaults to this class's bundle identifier.
 */
@property RG_NULLABLE_PROPERTY(nonatomic, strong, readonly) NSString* namespace;

/**
 @brief keychain accepts an account name which will be passed this value if provided.
 */
@property RG_NULLABLE_PROPERTY(nonatomic, strong, readonly) NSString* accountName;

/**
 @brief The default accessibility when assigning to the keychain, defaults to `kSecAttrAccessibleAfterFirstUnlock`.
 @note On OS X 7 and 8 the value of this property is sent along with the data, but it is ignored by the system.
 */
@property RG_NONNULL_PROPERTY(nonatomic, assign, readonly) CFStringRef itemAccessibility;

/**
 @return the singleton instance for managing access to the key chain.  Uses the default namespace.
 */
+ (RG_PREFIX_NONNULL RGLockbox*) manager;

/**
 @brief This is the queue on which all keychain accesses are performed.  You do not need to use this to synchronize
   operations, rather for program correctness you should `dispatch_barrier_sync()` on this queue when your program is
   about to become inactive.
 @return the serial queue on which keychain access is performed.  Only use as described.
 */
+ (RG_PREFIX_NONNULL dispatch_queue_t) keychainQueue;

/**
 @brief Tests whether the cache has a value.
 @param key the key on which to check the cache.  `.namespace` and `accountName` will be applied if available.
 @return `nil` if never seen before.  `+[NSNull null]` if seen but the value was not found.  Otherwise `NSData`.
 */
- (RG_PREFIX_NULLABLE id) testCacheForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 @param namespace an optional `NSString` to append to the front of the key given for writing and reading.  Passing `nil`
   will not prefix it with anything.  The default with `-init` is `rg_bundle_identifier()`.
 @param accessibility an optional `CFStringRef` to modify the accessibility of the items written.  Pass `nil` for the
   default which is `kSecAttrAccessibleAfterFirstUnlock`.  See <Security/SecItem.h> for other options.
 @return an instance of `RGLockbox` which has the provided namespace and accessibility.
 @note On OS X 7 and 8 the value of `accessibility` is sent along with the data, but it is ignored by the system.
 */
- (RG_PREFIX_NONNULL instancetype) initWithNamespace:(RG_PREFIX_NULLABLE NSString*)namespace
                                       accessibility:(RG_PREFIX_NULLABLE CFStringRef)accessibility
                                         accountName:(RG_PREFIX_NULLABLE NSString*)account NS_DESIGNATED_INITIALIZER;

/**
 @brief Primitive method to return the data on `key`.  Threadsafe.
 @param key the key from which to retrieve the output data.
 @return the data found if any on `key` in the current namespace.
 */
- (RG_PREFIX_NULLABLE NSData*) dataForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 @brief Primitive method to set the data on `key` and use the current value of `itemAccessibility`.  Threadsafe.
 @warning calling this method when the keychain is unavailable will raise an exception.
 */
- (void) setData:(RG_PREFIX_NULLABLE NSData*)data forKey:(RG_PREFIX_NONNULL NSString*)key;

@end
