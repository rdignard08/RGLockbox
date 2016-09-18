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

import Foundation
import libkern

/**
 Provides levels of logging suitable for different build environments.  Messages with severity greater than or equal to
 the current system severity will be logged.
*/
public enum RGLogSeverity: Int {
    /**
     Entire set of logging appropriate for debugging the library itself.
    */
    case trace
    
    /**
     Log messages useful for general debug and test builds.
    */
    case debug
    
    /**
     Log messages which might indicate something wrong.
    */
    case warning
    
    /**
     Log messages which indicate the system entered an error state.
    */
    case error
    
    /**
     Log messages which indicate an assertion or interrupt should happen.
    */
    case fatal
    
    /**
     Log level appropriate for messages which should always appear.
    */
    case none
}

#if DEBUG
    /**
     The system wide log level.
    */
    private var rg_systemSeverity = RGLogSeverity.debug
#else
    /**
     The system wide log level.
    */
    private var rg_systemSeverity = RGLogSeverity.none
#endif

/**
 The system wide log level.
 - returns: the currently set system severity.  When `DEBUG` is defined, defaults to `kRGLogSeverityDebug` otherwise
   defaults to `kRGLogSeverityNone`.
*/
public func rg_logging_severity() -> RGLogSeverity {
    return rg_systemSeverity
}

/**
 Provide the system logging level for subsequent log messages.
*/
public func rg_set_logging_severity(_ severity: RGLogSeverity) {
    rg_systemSeverity = severity
    OSMemoryBarrier()
}

/**
 String describing the log level.
 - returns: a string appropriate to describe the log level in English.
*/
private func rg_severityDescription(_ severity: RGLogSeverity) -> String {
    switch (severity) {
        case .trace:
            return "Trace, "
        case .debug:
            return "Debug, "
        case .warning:
            return "Warning, "
        case .error:
            return "Error, "
        case .fatal:
            return "Fatal, "
        case .none:
            return ""
    }
}

/**
 Whether this message should be logged.
 - returns: `true` if he severity is greater than or equal to the system log level.
*/
private func rg_shouldLog(_ severity: RGLogSeverity) -> Bool {
    return severity.rawValue >= rg_logging_severity().rawValue
}

/**
 A complete `NSLog()` replacement.  It logs the file name & line number. Severity will always log.
 - parameter message the string of the mesage after `line` info.  It is a programmer error to pass `nil`.
 - parameter file the name of the file where the log was called.  Cannot be `NULL`.
 - parameter line the line number of the log call.
 */
@available(*, deprecated : 2.2.5) public func RGLog(_ message: String, _ file: String = #file, _ line: Int = #line) {
    RGLogs(.none, message, file, line)
}

/**
 A complete `NSLog()` replacement.  It logs the file name & line number. Severity will always log.
 - parameter severity the severity level of this log message.
 - parameter message the string of the mesage after `line` info.  It is a programmer error to pass `nil`.
 - parameter file the name of the file where the log was called.  Cannot be `NULL`.
 - parameter line the line number of the log call.
 */
public func RGLogs(_ severity: RGLogSeverity, _ message: String, _ file: String = #file, _ line: Int = #line) {
    if rg_shouldLog(severity) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let severityDescription = rg_severityDescription(severity)
        print("[\(fileName):\(line)] \(severityDescription)\(message)")
    }
}
