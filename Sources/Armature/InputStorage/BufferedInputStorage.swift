//
//  BufferedInputStorage.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

final class BufferedInputStorage: InputStorage {
    
    // This number come from flup
    private let maxBuffer = 102400 - 8192
    private var data: [UInt8] = []
    private let connection: Connection
    internal var contentLength: UInt16 = 0
    
    required init(conn: Connection) {
        self.connection = conn
    }
    
    required init(sock: Int32) {
        self.connection = RawConnection(sock: sock)
    }
    
    func readInto(inout buffer: [UInt8]) throws -> Int {
        
        // Application can read as much as contentLength stdin
        guard self.contentLength > 0 else {
            return 0
        }
        
        let maxToRead = min(Int(self.contentLength), buffer.count)
        while self.data.count < maxToRead {
            // Read more data
            self.connection.loop(true)
        }
       
        buffer[buffer.startIndex ... buffer.endIndex.predecessor()] = self.data[self.data.startIndex ... self.data.startIndex.advancedBy(Int(maxToRead - 1))]
        self.tryToShrinkBuffer(maxToRead)
        self.contentLength -= UInt16(maxToRead)
        
        return maxToRead
    }
    
    func addData(data: [UInt8]) {
        self.data.appendContentsOf(data)
    }
    
    private func tryToShrinkBuffer(len: Int) {
        self.data.removeFirst(len)
    }
}
