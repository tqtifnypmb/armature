//
//  BufferedOutputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class BufferedOutputStream: OutputStream {
    
    required public init() {
        
    }
    
    public func write(buffer: [UInt8]) -> Int {
        return 0
    }
    
    public func writeString(data: String) throws {
        let dataLen = data.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var dataBuffer = [UInt8].init(count: dataLen, repeatedValue: 0)
        guard data.toBytes(&dataBuffer) else {
            throw DataError.InvalidData
        }
        self.write(dataBuffer)
    }
}