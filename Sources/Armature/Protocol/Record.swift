//
//  Record.swift
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

final class Record {
  
    var type: RecordType = .UNKNOWN_TYPE
    var requestId: UInt16 = 0
    var contentLength: UInt16 = 0
    var contentData: [UInt8]?
    
    class func readFrom(conn: Connection) throws -> Record? {
        var buffer = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        try conn.readInto(&buffer)
    
        let record = Record()
        record.requestId = (UInt16(buffer[2]) << 8) + UInt16(buffer[3])
        record.contentLength = (UInt16(buffer[4]) << 8) + UInt16(buffer[5])
        let paddingLength = UInt32(buffer[6])
        
        if let type = RecordType(rawValue: buffer[1]) {
            record.type = type
        } else {
            // Ignore unsupport request type
            try skip(conn, len: UInt32(record.contentLength) + paddingLength)
            return nil
        }
        
        if record.contentLength > 0 {
            var data = [UInt8].init(count: Int(record.contentLength), repeatedValue: 0)
            try conn.readInto(&data)
            record.contentData = data
        }
        
        if paddingLength > 0 {
            try skip(conn, len: paddingLength)
        }
        
        return record
    }

    class func createEOFRecord(reqId: UInt16, type: RecordType) -> Record {
        let r = Record()
        r.type = type
        r.requestId = reqId
        r.contentLength = 0
        r.contentData = nil
        return r
    }
    
    private class func skip(conn: Connection, len: UInt32) throws {
        var ignore = [UInt8].init(count: Int(len), repeatedValue: 0)
        try conn.readInto(&ignore)
    }
    
    func writeTo(conn: Connection) throws {
        var paddingLength: UInt8 = 0
        if self.contentLength != 0 {
            paddingLength = UInt8(self.calPadding(self.contentLength, boundary: 8))
        }
        
        var heads = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        heads[0] = 1                                            // Version
        heads[1] = self.type.rawValue                           // Type
        heads[2] = UInt8(self.requestId >> 8)                   // Request ID
        heads[3] = UInt8(self.requestId & 0xFF)                 // Request ID
        heads[4] = UInt8(self.contentLength >> 8)               // Content Length
        heads[5] = UInt8(self.contentLength & 0xFF)             // Content Length
        heads[6] = paddingLength                                // Paddign Length
        heads[7] = 0                                            // Reserve
        
        // FIXME:  Is byte order important??
        try conn.write(&heads)
        if self.contentLength != 0 {
            try conn.write(&self.contentData!)
        }
        if paddingLength > 0 {
            var padding = [UInt8].init(count: Int(paddingLength), repeatedValue: 0)
            try conn.write(&padding)
        }
    }
    
    private func calPadding(n: UInt16, boundary: UInt16) -> UInt16 {
        guard n != 0 else {
            return boundary
        }
        return (~n + 1) & (boundary - 1)
    }
}
