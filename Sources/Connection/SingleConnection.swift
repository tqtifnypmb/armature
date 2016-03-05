//
//  SingleConnection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class SingleConnection: Connection {
    public let sock: Int32
    var stop = false
    var curRequest: Request?
    
    public var inputStreamType: InputStream.Type = RawInputStream.self
    public var outputStreamType: OutputStream.Type = RawOutputStream.self
    public var server: Server
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    private let isMultiplex = 0
    required public init(sock: Int32, server: Server) {
        self.sock = sock
        self.server = server
    }
    
    public func loop(once: Bool) {
        defer {
            if !once {
                close(self.sock)
            }
        }
        
        do {
            if once {
                // According to [RFC 3875], there're always as many data
                // as CONTENT_LENGTH unless web server close connection prematurely.
                // So it's safe to block here
                try waitForData(nil)
                try processInput()
            } else {
                self.inputStream = self.inputStreamType.init(sock: self.sock)
                self.outputStream = self.outputStreamType.init(sock: self.sock)
                while !self.stop {
                    try waitForData(nil)
                    try processInput()
                }
            }
        } catch {
        }
    }
    
    public func readInto(inout buffer: [UInt8]) throws -> Int {
        return try self.inputStream.readInto(&buffer)
    }
    
    public func write(inout data: [UInt8]) throws {
        try self.outputStream.write(&data)
    }
    
    public func abortRequest(reqId: UInt16) throws {
        self.halt()
    }
    
    public func halt() {
        self.stop = true
    }
    
    private func waitForData(timeout: UnsafeMutablePointer<timeval>) throws -> Bool {
        var read_set = fd_set()
        read_set.fds_bits.0 = self.sock
        
        var nready: Int32
        if timeout == nil {
            var t = timeval()
            t.tv_sec = 0
            //FIXME
            nready = select(self.sock + 1, &read_set, nil, nil, &t)
        } else {
            nready = select(self.sock + 1, &read_set, nil, nil, timeout)
        }
        if (nready == -1) {
            throw SocketError.SelectFailed(Socket.getErrorDescription())
        }
        return nready != 0
    }
    
    private func processInput() throws {
        guard let record = try Record.readFrom(self) else {
            return
        }
        switch record.type {
        case .GET_VALUE:
            try self.handleGetValue(record)
            break
            
        case .ABORT_REQUEST:
            try self.handleAbortRequest(record)
            break
            
        case .PARAMS:
            try self.handleParams(record)
            break
            
        case .STDIN:
            self.handleStdIn(record)
            break
            
        case .BEGIN_REQUEST:
            try self.handleBeginRequest(record)
            break
            
        case .DATA:
            self.handleData(record)
            break
            
        default:
            try self.handleUnknownType(record)
            break
        }
    }
    
    private func handleUnknownType(record: Record) throws {
        let ret = Record()
        ret.contentLength = 8
        ret.contentData = [UInt8].init(arrayLiteral: record.type.rawValue, 0, 0, 0, 0, 0, 0, 0)
        ret.type = RecordType.UNKNOWN_TYPE
        ret.requestId = 0
        try ret.writeTo(self)
    }
    
    private func handleGetValue(record: Record) throws {
        guard record.contentLength != 0 , let cntData = record.contentData else {
            return
        }
        
        let ret = Record()
        ret.type = RecordType.GET_VALUE_RESULT
        ret.requestId = 0
        var query = Utils.parseNameValueData(cntData)
        
        for name in query.keys {
            switch name {
            case FCGI_MAX_CONNS:
                query[name] = String(self.server.maxConnections)
                break
                
            case FCGI_MAX_REQS:
                query[name] = String(self.server.maxRequests)
                break
                
            case FCGI_MPXS_CONNS:
                query[name] = String(isMultiplex)
                break
                
            default:
                // Unknown query
                // Ignore it
                return
            }
        }
        ret.contentData = Utils.encodeNameValueData(query)
        ret.contentLength = UInt16(ret.contentData!.count)
        try ret.writeTo(self)
    }
    
    private func handleAbortRequest(record: Record) throws {
        //Just close the connection
        try self.abortRequest(record.requestId)
    }
    
    private func handleParams(record: Record) throws {
        guard let req = self.curRequest else {
            return
        }
        
        guard record.contentLength != 0 , let cntData = record.contentData else {
            // A empty params is sent
            // tick the request
            try self.server.handleRequest(req)
            self.curRequest = nil
            return
        }
        
        let params = Utils.parseNameValueData(cntData)
        req.setParams(params)
    }
    
    private func handleStdIn(record: Record) {
        guard let req = self.curRequest else {
            return
        }
        
        if record.contentLength > 0, let cntData = record.contentData {
            req.STDIN.addData(cntData)
        }
    }
    
    private func handleBeginRequest(record: Record) throws {
        do {
            let req = try Request(record: record, conn: self)
            self.curRequest = req
        } catch DataError.UnknownRole {
            // let unknown role error throws will tear down the connection
            return
        }
    }
    
    private func handleData(record: Record) {
        guard let req = self.curRequest else {
            return
        }
        
        if record.contentLength > 0, let cntData = record.contentData {
            req.DATA = cntData
        }
    }
}