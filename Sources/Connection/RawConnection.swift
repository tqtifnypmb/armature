//
//  RawConnection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class RawConnection: Connection {
    public var sock: Int32
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    public required init(sock: Int32, server _: Server) {
        self.sock = sock
        self.inputStream = RawInputStream.init(sock: self.sock)
        self.outputStream = RawOutputStream.init(sock: self.sock)
    }
    
    public init(sock: Int32) {
        self.sock = sock
        self.inputStream = RawInputStream.init(sock: self.sock)
        self.outputStream = RawOutputStream.init(sock: self.sock)
    }

    public func readInto(inout buffer: [UInt8]) throws -> Int {
        return try self.inputStream.readInto(&buffer)
    }
    
    public func write(inout data: [UInt8]) throws {
        try self.outputStream.write(&data)
    }
    
    public func abortRequest(reqId: UInt16) throws {}
    public func loop(once: Bool) {}
    public func halt() {}
}