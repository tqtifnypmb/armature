//
//  BufferedInputStorage.swift
//  Armature
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 tqtifnypmb
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

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
