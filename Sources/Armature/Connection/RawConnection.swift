//
//  RawConnection.swift
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

final class RawConnection: Connection {
    var sock: Int32

    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    required init(sock: Int32, server _: Server) {
        self.sock = sock
        self.inputStream = RawInputStream.init(sock: self.sock)
        self.outputStream = RawOutputStream.init(sock: self.sock)
    }
    
    init(sock: Int32) {
        self.sock = sock
        self.inputStream = RawInputStream.init(sock: self.sock)
        self.outputStream = RawOutputStream.init(sock: self.sock)
    }

    func readInto(inout buffer: [UInt8]) throws -> Int {
        return try self.inputStream.readInto(&buffer)
    }
    
    func readLength(len: Int) throws -> [UInt8] {
        var buffer = [UInt8].init(count: len, repeatedValue: 0)
        let nread = try self.readInto(&buffer)
        if nread < len {
            buffer = [UInt8].init(buffer.dropLast(len - nread))
        }
        return buffer
    }
    
    func write(inout data: [UInt8]) throws {
        try self.outputStream.write(&data)
    }
    
    func loop(once: Bool) {}

    func halt() {}
}
