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

#import "RGLockbox+Convenience.h"

static NSDateFormatter* rg_stored_dateformatter() {
    static NSString* const _sIsoFormat = @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
    static NSString* const _sStoreFormatterKey = @"rg_stored_dateformatter";
    NSDateFormatter* formatter = [NSThread currentThread].threadDictionary[_sStoreFormatterKey];
    if (!formatter) {
        formatter = [NSDateFormatter new];
        formatter.dateFormat = _sIsoFormat;
        [NSThread currentThread].threadDictionary[_sStoreFormatterKey] = formatter;
    }
    return formatter;
}

@implementation RGLockbox (Convenience)

- (RG_PREFIX_NULLABLE id) JSONObjectForKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = [self dataForKey:key];
    return data ? [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil] : nil;
}

- (void) setJSONObject:(RG_PREFIX_NULLABLE id)object forKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = object ? [NSJSONSerialization dataWithJSONObject:(id RG_SUFFIX_NONNULL)object
                                                            options:(NSJSONWritingOptions)0
                                                              error:nil] : nil;
    [self setData:data forKey:key];
}

- (RG_PREFIX_NULLABLE NSDate*) dateForKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = [self dataForKey:key];
    if (data) {
        NSString* dateString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return [rg_stored_dateformatter() dateFromString:dateString];
    }
    return nil;
}

- (void) setDate:(RG_PREFIX_NULLABLE NSDate*)date forKey:(RG_PREFIX_NONNULL NSString*)key {
    NSString* dateString = date ? [rg_stored_dateformatter() stringFromDate:(id RG_SUFFIX_NONNULL)date] : nil;
    [self setData:[dateString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (RG_PREFIX_NULLABLE NSString*) stringForKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = [self dataForKey:key];
    return data ? [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] : nil;
}

- (void) setString:(RG_PREFIX_NULLABLE NSString*)string forKey:(RG_PREFIX_NONNULL NSString*)key {
    [self setData:[string dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
}

- (RG_PREFIX_NULLABLE id<NSCoding>) codeableForKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = [self dataForKey:key];
    return data ? [NSKeyedUnarchiver unarchiveObjectWithData:data] : nil;
}

- (void) setCodeable:(RG_PREFIX_NULLABLE id<NSCoding>)codeable forKey:(RG_PREFIX_NONNULL NSString*)key {
    NSData* data = codeable ? [NSKeyedArchiver archivedDataWithRootObject:(id RG_SUFFIX_NONNULL)codeable] : nil;
    [self setData:data forKey:key];
}

@end
