/* Copyright (c) 06/22/2014, Ryan Dignard
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

#ifndef RG_NULLABLE_PROPERTY
    #if __has_feature(nullability)
/**
 @brief This property can be `nil`.
 */
        #define RG_NULLABLE_PROPERTY(...) (nullable, ## __VA_ARGS__)
/**
 @brief This property can not be `nil`.
 */
        #define RG_NONNULL_PROPERTY(...) (nonnull, ## __VA_ARGS__)
/**
 @brief The getter of this property can never return `nil`, but `nil` is an acceptable assignment.
 */
        #define RG_NULL_RESETTABLE_PROPERTY(...) (null_resettable, ## __VA_ARGS__)
/**
 @brief This declaration goes before a variable and allows `nil` values.
 */
        #define RG_PREFIX_NULLABLE nullable
/**
 @brief This declaration goes after a variable and allows `nil` values.
 */
        #define RG_SUFFIX_NULLABLE __nullable
/**
 @brief This declaration goes before a variable that does not allow `nil` values.
 */
        #define RG_PREFIX_NONNULL nonnull
/**
 @brief This declaration goes after a variable that does not allow `nil` values.
 */
        #define RG_SUFFIX_NONNULL __nonnull
    #else
/**
 @brief This property can be `nil`.
 */
        #define RG_NULLABLE_PROPERTY(...) (__VA_ARGS__)
/**
 @brief This property can not be `nil`.
 */
        #define RG_NONNULL_PROPERTY(...) (__VA_ARGS__)
/**
 @brief The getter of this property can never return `nil`, but `nil` is an acceptable assignment.
 */
        #define RG_NULL_RESETTABLE_PROPERTY(...) (__VA_ARGS__)
/**
 @brief This declaration goes before a variable and allows `nil` values.
 */
        #define RG_PREFIX_NULLABLE
/**
 @brief This declaration goes after a variable and allows `nil` values.
 */
        #define RG_SUFFIX_NULLABLE
/**
 @brief This declaration goes before a variable that does not allow `nil` values.
 */
        #define RG_PREFIX_NONNULL
/**
 @brief This declaration goes after a variable that does not allow `nil` values.
 */
        #define RG_SUFFIX_NONNULL
    #endif
#endif

#ifndef RG_GENERIC
    #if __has_feature(objc_generics)
/**
 @brief This collection only accepts inputs of the given type and only returns the same.
 */
        #define RG_GENERIC(...) < __VA_ARGS__ >
    #else
/**
 @brief This collection only accepts inputs of the given type and only returns the same.
 */
        #define RG_GENERIC(...)
    #endif
#endif

#ifndef RG_VOID_NOOP
/**
 @brief `NULL` and `nil` are typed `void*` and I need it to be typed `void`
 */
    #define RG_VOID_NOOP ((void)0)
#endif

#ifndef RG_STRING_SEL
/**
 @brief Enables selector declarations to be used in place of an `NSString`, provides spell checking.
 */
    #ifdef DEBUG
        #define RG_STRING_SEL(sel) (YES ? @ # sel : NSStringFromSelector(@selector(sel)))
    #else
        #define RG_STRING_SEL(sel) @ # sel
    #endif
#endif
