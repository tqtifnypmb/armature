//
//  BufferedOutputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

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
