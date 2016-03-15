//
//  MultiplexConnection.swift
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

public class MultiplexConnection: SingleConnection {
    var requests: [UInt16 : FCGIRequest] = [:]
    var reqLock = NSLock()
    var streamLock = NSLock()
    let connectionQueue = NSOperationQueue()

    required public init(sock: Int32, server: Server) {
        super.init(sock: sock, server: server)
        self.isMultiplex = 1
    }
    
    override public func readInto(inout buffer: [UInt8]) throws -> Int {
        self.streamLock.lock()
        defer {
            self.streamLock.unlock()
        }
        return try super.readInto(&buffer)
    }
    
    override public func write(inout data: [UInt8]) throws {
        self.streamLock.lock()
        defer {
            self.streamLock.unlock()
        }
        try super.write(&data)
    }
    
    override func handleParams(record: Record) throws {
        self.reqLock.lock()
        defer {
            self.reqLock.unlock()
        }
        
        guard let req = self.requests[record.requestId] else {
            return
        }
        self.curRequest = req
        try super.handleParams(record)
    }
    
    override func handleStdIn(record: Record) {
        self.reqLock.lock()
        defer {
            self.reqLock.unlock()
        }
        
        guard let req = self.requests[record.requestId] else {
            return
        }
        self.curRequest = req
        super.handleStdIn(record)
    }
    
    override func handleBeginRequest(record: Record) throws {
        do {
            let req = try FCGIRequest(record: record, conn: self)
            self.reqLock.lock()
            self.requests[record.requestId] = req
            self.reqLock.unlock()
        } catch DataError.UnknownRole {
            // let unknown role error throws will tear down the connection
            return
        }
    }
    
    override func handleData(record: Record) {
        self.reqLock.lock()
        defer {
            self.reqLock.unlock()
        }
        
        guard let req = self.requests[record.requestId] else {
            return
        }
        self.curRequest = req
        super.handleData(record)
    }
    
    override func handleAbortRequest(record: Record) throws {
        self.reqLock.lock()
        defer {
            self.reqLock.unlock()
        }
        
        guard let req = self.requests[record.requestId] else {
            return
        }
        
        if req.isRunning {
            req.abort()
        } else {
            self.requests.removeValueForKey(record.requestId)
        }
    }
    
    override func serveRequest(req: FCGIRequest) throws {
        self.connectionQueue.addOperationWithBlock() {
            do {
                let fcgiServer = self.server as! FCGIServer
                try fcgiServer.handleRequest(req)
            } catch {
                // One request failed , broke down the whole connection
                self.halt()
                return
            }
            self.reqLock.lock()
            self.requests.removeValueForKey(req.requestId)
            self.reqLock.unlock()
        }
    }
}
