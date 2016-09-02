/* Copyright (c) 08/07/2016, Ryan Dignard
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

/**
 Some variants of the built-in va_list do not allow a nullability annotation.  This is a problem with -Werror
 */
typedef void* rg_va_list;

/**
 Provides levels of logging suitable for different build environments.  Messages with severity greater than or equal to 
  the current system severity will be logged.
 */
typedef NS_ENUM(int32_t, RGLogSeverity) {
    /**
     Entire set of logging appropriate for debugging the library itself.
     */
    kRGLogSeverityTrace,
    
    /**
     Log messages useful for general debug and test builds.
     */
    kRGLogSeverityDebug,
    
    /**
     Log messages which might indicate something wrong.
     */
    kRGLogSeverityWarning,
    
    /**
     Log messages which indicate the system entered an error state.
     */
    kRGLogSeverityError,
    
    /**
     Log messages which indicate an assertion or interrupt should happen.
     */
    kRGLogSeverityFatal,
    
    /**
     Log level appropriate for messages which should always appear.
     */
    kRGLogSeverityNone
};

/**
 @brief returns the currently set system severity.  When `DEBUG` is defined, defaults to `kRGLogSeverityDebug` otherwise
  defaults to `kRGLogSeverityNone`.
 */
RGLogSeverity rg_logging_severity(void);

/**
 @brief provide the system logging level for subsequent log messages.
 */
void rg_set_logging_severity(RGLogSeverity severity);

/**
 @brief A complete `NSLog()` replacement.  It logs the file name & line number.
 @param severity the severity level of this log message
 @param format the format string of the arguments _after_ lineNumber.  It is a programmer error to pass `nil`.
 @param file the name of the file where the log was called.  Cannot be `NULL`.
 @param line the line number of the log call.
 @param ... values that will be called with `format` to generate the output.
 */
void rg_log_severity(RGLogSeverity severity,
                     NSString* RG_SUFFIX_NONNULL format,
                     const char* RG_SUFFIX_NONNULL const file,
                     unsigned long line,
                     ...);

/**
 @brief A complete `NSLogv()` replacement.  It logs the file name & line number.
 @param severity the severity level of this log message
 @param format the format string of the arguments _after_ lineNumber.  It is a programmer error to pass `nil`.
 @param file the name of the file where the log was called.  Cannot be `NULL`.
 @param line the line number of the log call.
 @param args values that will be called with `format` to generate the output.
 */
void rg_log_severity_v(RGLogSeverity severity,
                       NSString* RG_SUFFIX_NONNULL format,
                       const char* RG_SUFFIX_NONNULL const file,
                       unsigned long line,
                       rg_va_list RG_SUFFIX_NONNULL args);

/**
 @brief A complete `NSLog()` replacement.  It logs the file name & line number.
 @param severity the severity level of this log message
 @param format the format string of the arguments _after_ lineNumber.  It is a programmer error to pass `nil`.
 @param file the name of the file where the log was called.  Cannot be `NULL`.
 @param line the line number of the log call.
 @param ... values that will be called with `format` to generate the output.
 @deprecated Use RGLogs(severity, format, ...)
 */
void rg_dep_log(RGLogSeverity severity,
                NSString* RG_SUFFIX_NONNULL format,
                const char* RG_SUFFIX_NONNULL const file,
                unsigned long line,
                ...) __attribute__((deprecated));

#ifndef RGLog /* provide this to match the old behavior */
    #ifdef DEBUG
        #define RGLog(format, ...) rg_dep_log(kRGLogSeverityNone, format, __FILE__, __LINE__, ## __VA_ARGS__)
    #else
        #define RGLog(...) RG_VOID_NOOP
    #endif
#endif

#ifndef RGLogs /* new macro which takes a severity argument */
    #define RGLogs(severity, format, ...) rg_log_severity(severity, format, __FILE__, __LINE__, ## __VA_ARGS__)
#endif

