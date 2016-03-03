//
//  BufferedInputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class BufferedInputStream: InputStream {
    private var data: [UInt8] = []
    private var pos = 0
    
    required init() {
        
    }
    
    func readInto(inout buffer: [UInt8]) -> Int {
        let len = min(buffer.count - pos, self.data.count)
        guard len > 0 else {
            // FIXME
            // Try read from server
            return len
        }
        buffer[0 ... len] = self.data[pos ... pos + len - 1]
        return len
    }
    
    func addData(dataToAdd: [UInt8]) {
        self.data.appendContentsOf(dataToAdd)
    }
}