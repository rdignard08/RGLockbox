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

#import "RGLog.h"
#import <libkern/OSAtomic.h>

#ifdef DEBUG
static volatile RGLogSeverity rg_systemSeverity = kRGLogSeverityDebug;
#else
static volatile RGLogSeverity rg_systemSeverity = kRGLogSeverityNone;
#endif

RGLogSeverity rg_logging_severity(void) {
    return rg_systemSeverity;
}

void rg_set_logging_severity(RGLogSeverity severity) {
    rg_systemSeverity = severity;
    OSMemoryBarrier();
}

static const char * const rg_severityDescription(RGLogSeverity severity) {
    switch (severity) {
        case kRGLogSeverityTrace:
            return "Trace, ";
        case kRGLogSeverityDebug:
            return "Debug, ";
        case kRGLogSeverityWarning:
            return "Warning, ";
        case kRGLogSeverityError:
            return "Error, ";
        case kRGLogSeverityFatal:
            return "Fatal, ";
        case kRGLogSeverityNone:
            return "";
    }
    return "";
}

static BOOL rg_shouldLog(RGLogSeverity severity) {
    return severity >= rg_logging_severity();
}

void rg_dep_log(RGLogSeverity severity,
                NSString* RG_SUFFIX_NONNULL format,
                const char* RG_SUFFIX_NONNULL const file,
                unsigned long line,
                ...) {
    va_list arguments;
    va_start(arguments, line);
    rg_log_severity_v(severity, format, file, line, arguments);
    va_end(arguments);
}

void rg_log_severity(RGLogSeverity severity,
                     NSString * RG_SUFFIX_NONNULL format,
                     const char * RG_SUFFIX_NONNULL const file,
                     unsigned long line,
                     ...) {
    va_list arguments;
    va_start(arguments, line);
    rg_log_severity_v(severity, format, file, line, arguments);
    va_end(arguments);
}

void rg_log_severity_v(RGLogSeverity severity,
                       NSString* RG_SUFFIX_NONNULL format,
                       const char* RG_SUFFIX_NONNULL const file,
                       unsigned long line,
                       rg_va_list args) {
    if (rg_shouldLog(severity)) {
        const char * fileName = file;
        for (size_t i = strlen(file); i > 0; i--) {
            if (file[i] == '/') {
                fileName = file + i + 1;
                break;
            }
        }
        NSString* userOutput = [[NSString alloc] initWithFormat:format arguments:args];
        const char * const severityDescription = rg_severityDescription(severity);
        fprintf(stderr, "[%s:%lu] %s%s\n", fileName, line, severityDescription, userOutput.UTF8String);
    }
}
