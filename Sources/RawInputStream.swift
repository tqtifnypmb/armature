//
//  BufferedInputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class RawInputStream: InputStream {
    private let sock: Int32
    required init(sock: Int32) {
        self.sock = sock
    }
    
    func readInto(inout buffer: [UInt8]) throws -> Int {
        let nread = read(self.sock, &buffer , Int(buffer.count))
        if nread == -1 {
            throw SocketError.ReadFailed(Socket.getErrorDescription())
        } else if nread == 0 {
            throw SocketError.ReadFailed("Trying to read a closed socket")
        }
        return nread
    }
    
    func readN(buffer: UnsafeMutablePointer<Void>, n: UInt32) throws {
        var remain = n
        let ptr = buffer
        while remain > 0 {
            let nread = read(sock, ptr.advancedBy(Int(n - remain)) , Int(remain))
            if (nread == -1) {
                throw SocketError.ReadFailed(Socket.getErrorDescription())
            }
            remain -= UInt32(nread)
        }
    }
}