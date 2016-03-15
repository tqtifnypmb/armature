//
//  CGIRequest.swift
//  Armature
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 tqtifnypmb
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

final class CGIRequest: Request {
    var requestId: UInt16 = 0
    var STDIN: InputStorage
    var STDOUT: OutputStorage
    var STDERR: OutputStorage
    var DATA: [UInt8]?
    var params: [String : String] = [:] {
        didSet {
            if let cnt = params["CONTENT_LENGTH"], let cntLen = UInt16(cnt) {
                self.STDIN.contentLength = cntLen
            }
        }
    }
    var isRunning: Bool = false
    
    init() {
        self.STDIN = BufferedInputStorage(sock: STDIN_FILENO)
        self.STDOUT = BufferedOutputStorage(sock: STDOUT_FILENO, isErr: false)
        self.STDERR = BufferedOutputStorage(sock: STDERR_FILENO, isErr: true)
        self.params = NSProcessInfo.processInfo().environment
    }
    
    func finishHandling() throws {
        try self.STDOUT.flush()
        try self.STDERR.flush()
    }
    
    var isAborted: Bool {
        return false
    }
}
