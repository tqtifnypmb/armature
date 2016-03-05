//
//  Record.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public final class Record {
    //var version: UInt8 = 1
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
            // FIXME log may be necessary
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
        heads[2] = 0                                            // Request ID
        heads[3] = 0                                            // Request ID
        heads[4] = UInt8(self.contentLength >> 8)               // Content Length
        heads[5] = UInt8(self.contentLength & 0xFF)             // Content Length
        heads[6] = paddingLength                                // Paddign Length
        heads[7] = 0                                            // Reserve
        
        // FIXME  Is byte order important??
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