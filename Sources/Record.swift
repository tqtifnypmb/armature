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
    
    class func readFrom(sock: Int32) throws -> Record? {
        var buffer = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        try Utils.readN(sock, buffer: &buffer, n: UInt32(FCGI_HEADER_LEN))
        
        let record = Record()
        record.requestId = UInt16(buffer[2]) << 8 + UInt16(buffer[3])
        record.contentLength = UInt16(buffer[4]) << 8 + UInt16(buffer[5])
        let paddingLength = UInt32(buffer[6])
        
        if let type = RecordType(rawValue: buffer[1]) {
            record.type = type
        } else {
            // Ignore unsupport request type
            // FIXME log may be necessary
            try skip(sock, len: UInt32(record.contentLength) + paddingLength)
            return nil
        }
        
        if record.contentLength > 0 {
            var data = [UInt8].init(count: Int(record.contentLength), repeatedValue: 0)
            try Utils.readN(sock, buffer: &data, n: UInt32(record.contentLength))
            record.contentData = data
        }
        try skip(sock, len: paddingLength)
        return record
    }

    class func skip(sock: Int32, len: UInt32) throws {
        var ignore = [UInt8].init(count: Int(len), repeatedValue: 0)
        try Utils.readN(sock, buffer: &ignore, n: len)
    }
    
    func writeTo(sock: Int32) throws {
        var paddingLength = UInt8(self.calPadding(self.contentLength, boundary: 8))
        if self.contentLength == 0 {
            paddingLength = 0
        }
        
        var heads = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        heads[0] = 1                                            // Version
        heads[1] = RecordType.GET_VALUE_RESULT.rawValue         // Type
        heads[2] = 0                                            // Request ID
        heads[3] = 0                                            // Request ID
        heads[4] = UInt8(self.contentLength >> 8)               // Content Length
        heads[5] = UInt8(self.contentLength & 0x01)             // Content Length
        heads[6] = paddingLength                                // Paddign Length
        heads[7] = 0                                            // Reserve
        
        // FIXME  Consider byte order !!!
        try Utils.writeN(sock, data: &heads, n: UInt32(FCGI_HEADER_LEN))
        if self.contentLength != 0 {
            try Utils.writeN(sock, data: &self.contentData!, n: UInt32(self.contentLength))
        }
        if paddingLength > 0 {
            var padding = [UInt8].init(count: Int(paddingLength), repeatedValue: 0)
            try Utils.writeN(sock, data: &padding, n: UInt32(paddingLength))
        }
    }
    
    private func calPadding(n: UInt16, boundary: UInt16) -> UInt16 {
        return (~n + 1) & (boundary - 1)
    }
}