//
//  Utils.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

internal final class Utils {
    static func readN(sock: Int32, buffer: UnsafeMutablePointer<Void>, n: UInt32) throws {
        var remain = n
        while remain > 0 {
            let nread = read(sock, buffer.advancedBy(Int(n - remain)) , Int(remain))
            if (nread == -1) {
                throw SocketError.ReadFailed(Socket.getErrorDescription())
            }
            remain -= UInt32(nread)
        }
    }
    
    static func writeN(sock: Int32, data: UnsafeMutablePointer<Void>, n: UInt32) throws {
        var remain = n
        while remain > 0 {
            let nread = write(sock, data.advancedBy(Int(n - remain)) , Int(remain))
            if (nread == -1) {
                throw SocketError.ReadFailed(Socket.getErrorDescription())
            }
            remain -= UInt32(nread)
        }
    }
    
    static func parseNameValueData(dataToParse: [UInt8]) -> [String: String?] {
        let hightBixMask: UInt8 = 1 << 7
        
        var index = 0
        var params: [String : String] = [:]
        while index < dataToParse.count {
            
            var nameLength: UInt32 = 0
            for ; index < dataToParse.count ; ++index {
                let byte = dataToParse[index]
                nameLength = nameLength << 8 + UInt32(byte)
                if hightBixMask & byte == 0 {
                    break
                }
            }
            
            var valueLength: UInt32 = 0
            for ; index < dataToParse.count ; ++index {
                let byte = dataToParse[index]
                valueLength = valueLength << 8 + UInt32(byte)
                if hightBixMask & byte == 0 {
                    break
                }
            }

            var name: String?
            var value: String?
            if nameLength > 0 {
                let nameBytes = dataToParse[dataToParse.startIndex.advancedBy(index) ... dataToParse.startIndex.advancedBy(index + Int(nameLength))]
                name = String.init(bytes: nameBytes, encoding: NSUTF8StringEncoding)
            }
            if valueLength > 0 {
                let valueBytes = dataToParse[dataToParse.startIndex.advancedBy(index + Int(nameLength)) ... dataToParse.startIndex.advancedBy(index + Int(nameLength) + Int(valueLength))]
                value = String.init(bytes: valueBytes, encoding: NSUTF8StringEncoding)
            }
            
            if let name = name {
                params[name] = value
            }
        }
        return params
    }
    
    static func encodeNameValueData(dataToEncode: [String : String?]) -> [UInt8] {
        var ret: [UInt8] = []
        for (name , value) in dataToEncode {
            guard let value = value else {
                continue
            }
            let nameLen = name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            var nameBuffer = [UInt8].init(count:nameLen, repeatedValue: 0)
            guard name.getBytes(&nameBuffer,
                maxLength: nameLen,
                usedLength: nil,
                encoding: NSUTF8StringEncoding,
                options: .AllowLossy,
                range: Range(start: name.startIndex, end: name.endIndex),
                remainingRange: nil) == true else {
                continue
            }
            
            let valueLen = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            var valueBuffer = [UInt8].init(count: valueLen, repeatedValue: 0)
            
            guard value.getBytes(&valueBuffer,
                maxLength: valueLen,
                usedLength: nil,
                encoding: NSUTF8StringEncoding,
                options: .AllowLossy,
                range: Range(start: name.startIndex,
                    end: name.endIndex),
                remainingRange: nil) == true else {
                continue
            }
            
            ret.appendContentsOf(encodeLength(nameLen))
            ret.appendContentsOf(encodeLength(valueLen))
            ret.appendContentsOf(nameBuffer)
            ret.appendContentsOf(valueBuffer)
            
        }
        return ret
    }
    
    static func encodeLength(len: Int) -> [UInt8] {
        let lastByteMask = 0xFF
        var lenInBytes: [UInt8] = []
        while len & lastByteMask != 0 {
            lenInBytes.insert(UInt8(len & lastByteMask), atIndex: 0)
            len >> 8
        }
        return lenInBytes
    }
    
    static func isLittleEndian() -> Bool {
        return Int(OSHostByteOrder()) == OSLittleEndian
    }
}
