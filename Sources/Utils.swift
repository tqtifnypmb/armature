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
        var params: [String : String?] = [:]
        while index < dataToParse.count {
            
            var nameLength: UInt32 = 0
            while index < dataToParse.count {
                let byte = dataToParse[index]
                index += 1
                
                if hightBixMask & byte == 1 {
                    let firstBytes = nameLength == 0
                    firstBytes ? (nameLength << 8 + UInt32(byte)) & 0x7f : nameLength << 8 + UInt32(byte)
                } else {
                    nameLength = nameLength << 8 + UInt32(byte)
                    break
                }
            }
            
            var valueLength: UInt32 = 0
            while index < dataToParse.count {
                let byte = dataToParse[index]
                index += 1
                
                if hightBixMask & byte == 1 {
                    let firstBytes = valueLength == 0
                    firstBytes ? (valueLength << 8 + UInt32(byte)) & 0x7f : valueLength << 8 + UInt32(byte)
                } else {
                    valueLength = valueLength << 8 + UInt32(byte)
                    break
                }
            }
            
            var name: String?
            var value: String?
            if nameLength > 0 {
                let nameBytes = dataToParse[dataToParse.startIndex.advancedBy(index) ... dataToParse.startIndex.advancedBy(index + Int(nameLength) - 1)]
                name = String.init(bytes: nameBytes, encoding: NSUTF8StringEncoding)
                index += Int(nameLength)
            }
            if valueLength > 0 {
                let valueBytes = dataToParse[dataToParse.startIndex.advancedBy(index) ... dataToParse.startIndex.advancedBy(index + Int(valueLength) - 1)]
                value = String.init(bytes: valueBytes, encoding: NSUTF8StringEncoding)
                index += Int(valueLength)
            }
            
            if let name = name {
                params[name] = value
            }
        }
        return params
    }
    
    static func encodeNameValueData(dataToEncode: [String : String]) -> [UInt8] {
        var ret: [UInt8] = []
        for (name , value) in dataToEncode {
            let nameLen = name.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            var nameBuffer = [UInt8].init(count:nameLen, repeatedValue: 0)
            guard name.toBytes(&nameBuffer) else {
                continue
            }
            
            let valueLen = value.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
            var valueBuffer = [UInt8].init(count: valueLen, repeatedValue: 0)
            guard value.toBytes(&valueBuffer) else {
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
        var length = len
        while length != 0 && length & lastByteMask != 0 {
            lenInBytes.insert(UInt8(length & lastByteMask), atIndex: 0)
            length >>= 8
        }
        return lenInBytes
    }
    
    static func isLittleEndian() -> Bool {
        return Int(OSHostByteOrder()) == OSLittleEndian
    }
}
