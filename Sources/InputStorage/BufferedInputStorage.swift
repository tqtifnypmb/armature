//
//  BufferedInputStorage.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class BufferedInputStorage: InputStorage {
    
    private let maxBuffer = 102400 - 8192
    private var data: [UInt8] = []
    private var pos = 0
    private let connection: Connection
    public var contentLength: UInt16 = 0
    required init(conn: Connection) {
        self.connection = conn
    }
    
    func readInto(inout buffer: [UInt8]) throws -> Int {
        guard self.contentLength > 0 else {
            return 0
        }
        
        let maxToRead = min(Int(self.contentLength), buffer.count)
        if self.data.count - pos < maxToRead {
            // FIXME 
            // What if there're more than one stdin record
            try self.connection.loop(true)
        }
        
        buffer[buffer.startIndex ... buffer.endIndex] = self.data[self.data.startIndex + pos ... self.data.endIndex]
        self.tryToShrinkBuffer()
        self.contentLength -= UInt16(maxToRead)
        return maxToRead
    }
    
    func addData(data: [UInt8]) {
        self.data.appendContentsOf(data)
        if self.data.count > self.maxBuffer {
            self.tryToShrinkBuffer()
        }
    }
    
    private func tryToShrinkBuffer() {
        guard self.pos != 0 else {
            return
        }
        self.data.removeFirst(self.pos)
    }
}