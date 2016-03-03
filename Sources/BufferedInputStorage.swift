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
    private var buffer: [UInt8] = []
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
        if self.buffer.count - pos < maxToRead {
            var remain = maxToRead - (self.buffer.count - pos)
            var data = [UInt8].init(count: remain, repeatedValue: 0)
            while remain > 0 {
                // Error !! Shouldn't read from connection. We should let connection loop againg instead
                // Consider multiplex
                let nread = try self.connection.readInto(&data)
                remain -= nread
            }
        }
        
        buffer[buffer.startIndex ... buffer.endIndex] = self.buffer[self.buffer.startIndex + pos ... self.buffer.endIndex]
        self.tryToShrinkBuffer()
        return maxToRead
    }
    
    func addData(data: [UInt8]) {
        self.buffer.appendContentsOf(data)
        if self.buffer.count > self.maxBuffer {
            self.tryToShrinkBuffer()
        }
    }
    
    private func tryToShrinkBuffer() {
        guard self.pos != 0 else {
            return
        }
        self.buffer.removeFirst(self.pos)
    }
}