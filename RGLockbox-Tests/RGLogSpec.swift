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
import XCTest
import RGLockbox

class RGLogSpec : XCTestCase {
    func testTraceMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.Trace)
        RGLogs(.Trace, "Hello Trace")
    }
    
    func testDebugMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.Debug)
        RGLogs(.Debug, "Hello Debug")
    }
    
    func testWarnMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.Warning)
        RGLogs(.Warning, "Hello Warn")
    }
    
    func testWarnMessageDoesntLog() {
        rg_set_logging_severity(RGLogSeverity.Error)
        RGLogs(.Warning, "No Warn")
    }
    
    func testErrorMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.Error)
        RGLogs(.Error, "Hello Error")
    }
    
    func testFatalMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.Fatal)
        RGLogs(.Fatal, "Hello Fatal")
    }
    
    func testNoneMessageLogs() {
        rg_set_logging_severity(RGLogSeverity.None)
        RGLogs(.None, "Hello None")
    }
}
