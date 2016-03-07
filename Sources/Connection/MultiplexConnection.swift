//
//  MultiplexConnection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/6/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

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
            defer {
                self.reqLock.unlock()
            }
            self.requests[record.requestId] = req
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
    
    override func serveRequest(req: FCGIRequest) throws {
        self.connectionQueue.addOperationWithBlock() {
            do {
                try self.server.handleRequest(req)
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