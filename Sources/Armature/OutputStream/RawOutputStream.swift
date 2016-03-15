//
//  BufferedOutputStream.swift
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

final class RawOutputStream: OutputStream {
    
    let sock: Int32
    required init(sock: Int32) {
        self.sock = sock
    }
    
    func write(inout buffer: [UInt8]) throws {
        return try Utils.writeN(self.sock, data: &buffer, n: UInt32(buffer.count))
    }
    
    func writeString(data: String) throws {
        let dataLen = data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var dataBuffer = [UInt8].init(count: dataLen, repeatedValue: 0)
        guard data.toBytes(&dataBuffer) else {
            throw DataError.InvalidData
        }
        try self.write(&dataBuffer)
    }
}
