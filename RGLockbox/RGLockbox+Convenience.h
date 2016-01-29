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

/**
 RGLockbox+Convenience defines several common ways to interact with the fundamental interface.  Supported inputs are: JSON, `NSDate`, `NSString`, `id<NSCoding>`.
 */
@interface RGLockbox (Convenience)

/**
 @return the data found on `key` if not `nil` passed through `+[NSJSONSerialization JSONObjectWithData:options:error:]` otherwise `nil`.
 @throw `NSInvalidArgumentException` if the data exists, but is not deserializable but `NSJSONSerialization`.
 */
- (RG_PREFIX_NULLABLE id) JSONObjectForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 @brief Sets any object of JSON type to the keychain.
 @param object an object of any JSON object type (`NSNumber`, `NSString`, `NSNull`, `NSArray`, `NSDictionary`).
 @param key key in the current namespace on which to store the output data.
 @throw `NSInvalidArgumentException` if the object is not valid JSON.
 */
- (void) setJSONObject:(RG_PREFIX_NULLABLE id)object forKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 @return the data found on `key` parsed to an `NSString` with UTF-8 decoding and run through a standard ISO date format.  `nil` on failure to parse or no data.
 */
- (RG_PREFIX_NULLABLE NSDate*) dateForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 @brief Sets an `NSDate` object to the keychain.
 @param date the date to store to the keychain, converted to a string then UTF-8 data; `nil` removes any set value.
 @param key key in the current namespace on which to store the output data.
 */
- (void) setDate:(RG_PREFIX_NULLABLE NSDate*)date forKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 
 */
- (RG_PREFIX_NULLABLE NSString*) stringForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 
 */
- (void) setString:(RG_PREFIX_NULLABLE NSString*)string forKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 
 */
- (RG_PREFIX_NULLABLE id<NSCoding>) codeableForKey:(RG_PREFIX_NONNULL NSString*)key;

/**
 
 */
- (void) setCodeable:(RG_PREFIX_NULLABLE id<NSCoding>)codeable forKey:(RG_PREFIX_NONNULL NSString*)key;

@end
