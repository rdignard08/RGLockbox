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

@interface RGLockbox (Convenience)

//// vvvv Old interface vvvv
//
///**
// @return `YES` in the event of success; otherwise `NO`.  Error messages are hard :(
//
// This is the "raw" insertion method.
// */
//+ (BOOL) setData:(NSData*)value forKey:(NSString*)key;
//
//+ (BOOL) setData:(NSData*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// @return the last value that was set for the given key.
//
// This is the "raw" access method.
// */
//+ (NSData*) dataForKey:(NSString*)key;
//
//+ (NSData*) dataForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// @throw NSInvalidArgument Will bail if `object` cannot be serialized by `NSJSONSerialization`.
// */
//+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key;
//
//+ (BOOL) setJSONObject:(id)object forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// If saved with +setJSONObject:forKey: the value can be recovered from this method.
// */
//+ (id) objectForKey:(NSString*)key;
//
//+ (id) objectForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Dates are not part of the JSON standard so they need to be handled in a separate way.
// */
//+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key;
//
//+ (BOOL) setDate:(NSDate*)date forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Retrieve a date set with +setDate:forKey:
// */
//+ (NSDate*) dateForKey:(NSString*)key;
//
//+ (NSDate*) dateForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Strings aren't allowed as top-level objects in JSON, and most things can become strings easily; hence this method.
// */
//+ (BOOL) setString:(NSString*)value forKey:(NSString*)key;
//
//+ (BOOL) setString:(NSString*)value forKey:(NSString*)key inNameSpace:(NSString*)nameSpace;
//
///**
// Returns as a string, the value set for key
// */
//+ (NSString*) stringForKey:(NSString*)key;
//
//+ (NSString*) stringForKey:(NSString*)key inNameSpace:(NSString*)nameSpace;

@end
