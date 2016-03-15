//
//  BufferedOutputStorage.swift
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

final class BufferedOutputStorage: OutputStorage {
    
    // This is number is from flup
    private let maxBuffer = 8192
    private var buffer: [UInt8] = []
    private let isErr: Bool
    private var connection: Connection!
    private let requestId: UInt16
    private var needEOF = false
    
    required init(conn: Connection, reqId: UInt16, isErr: Bool) {
        self.connection = conn
        self.isErr = isErr
        self.requestId = reqId
    }
    
    required init(sock: Int32, isErr: Bool) {
        self.connection = RawConnection(sock: sock)
        self.isErr = isErr
        self.requestId = 0
    }
    
    func write(data: [UInt8]) throws {
        self.needEOF = true
        self.buffer.appendContentsOf(data)
        if self.buffer.count >= self.maxBuffer {
            try self.buildRecord().writeTo(self.connection)
            self.buffer.removeAll(keepCapacity: true)
        }
    }
    
    func writeString(str: String) throws {
        var buffer = [UInt8].init(count: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), repeatedValue: 0)
        str.toBytes(&buffer)
        try self.write(buffer)
    }
    
    func flush() throws {
        guard self.buffer.count > 0 else {
            return
        }
        try self.buildRecord().writeTo(self.connection)
        self.buffer.removeAll(keepCapacity: true)
    }
    
    func writeEOF() throws {
        guard self.needEOF else {
            return
        }
        
        let type = self.isErr == true ? RecordType.STDERR: RecordType.STDOUT
        let eof = Record.createEOFRecord(self.requestId, type: type)
        try eof.writeTo(self.connection)
    }
    
    private func buildRecord() -> Record {
        let record = Record()
        record.requestId = self.requestId
        record.type = (self.isErr ? RecordType.STDERR : RecordType.STDOUT)
        record.contentLength = UInt16(self.buffer.count)
        record.contentData = self.buffer
        return record
    }
}
