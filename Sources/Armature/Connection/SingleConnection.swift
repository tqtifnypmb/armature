//
//  SingleConnection.swift
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

public class SingleConnection: Connection {
    var curRequest: FCGIRequest?
    var isMultiplex: Int
    var server: Server
    
    private let sock: Int32
    private var stop = false
    
    private let inputStream: InputStream
    private let outputStream: OutputStream

    required public init(sock: Int32, server: Server) {
        self.sock = sock
        self.server = server
        self.isMultiplex = 0
        
        self.inputStream = RawInputStream(sock: self.sock)
        self.outputStream = RawOutputStream(sock: self.sock)
    }
    
    public func loop(once: Bool) {
        defer {
            if !once {
                close(self.sock)
            }
        }
        
        do {
            while !self.stop {
                try waitForData(nil)
                try processInput()
                
                if once {
                    break
                }
            }
        } catch {
            self.stop = true
        }
    }
    
    public func readLength(len: Int) throws -> [UInt8] {
        var buffer = [UInt8].init(count: len, repeatedValue: 0)
        let nread = try self.readInto(&buffer)
        if nread < len {
            buffer = [UInt8].init(buffer.dropLast(len - nread))
        }
        return buffer
    }
    
    public func readInto(inout buffer: [UInt8]) throws -> Int {
        return try self.inputStream.readInto(&buffer)
    }
    
    public func write(inout data: [UInt8]) throws {
        try self.outputStream.write(&data)
    }
    
    public func halt() {
        self.stop = true
    }
    
    private func waitForData(timeout: UnsafeMutablePointer<timeval>) throws -> Bool {
        var nfd = pollfd()
        nfd.fd = self.sock
        nfd.events = Int16(POLLIN)
        let ret = poll(&nfd, 1, -1)
        if ret == -1 {
            throw SocketError.SelectFailed(Socket.getErrorDescription())
        }
        return ret != 0
    }
    
    private func processInput() throws {
        guard let record = try Record.readFrom(self) else {
            return
        }
        switch record.type {
        case .GET_VALUE:
            try self.handleGetValue(record)
            
        case .ABORT_REQUEST:
            try self.handleAbortRequest(record)
            
        case .PARAMS:
            try self.handleParams(record)
            
        case .STDIN:
            self.handleStdIn(record)
            
        case .BEGIN_REQUEST:
            try self.handleBeginRequest(record)
            
        case .DATA:
            self.handleData(record)
            
        default:
            try self.handleUnknownType(record)
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
    
    func handleGetValue(record: Record) throws {
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
                
            case FCGI_MAX_REQS:
                query[name] = String(self.server.maxRequests)
                
            case FCGI_MPXS_CONNS:
                query[name] = String(isMultiplex)
                
            default: break
                // Unknown query
                // Ignore it
            }
        }
        ret.contentData = Utils.encodeNameValueData(query)
        ret.contentLength = UInt16(ret.contentData!.count)
        try ret.writeTo(self)
    }
    
    func handleAbortRequest(record: Record) throws {
        //Just close the connection
        self.halt()
    }
    
    func handleParams(record: Record) throws {
        guard let req = self.curRequest else {
            return
        }
        
        guard record.contentLength != 0 , let cntData = record.contentData else {
            // A empty params is sent
            // tick the request
            try self.serveRequest(req)
            return
        }
        
        let params = Utils.parseNameValueData(cntData)
        req.params = params
    }
    
    func handleStdIn(record: Record) {
        guard let req = self.curRequest else {
            return
        }
        
        if record.contentLength > 0, let cntData = record.contentData {
            req.STDIN.addData(cntData)
        }
    }
    
    func handleBeginRequest(record: Record) throws {
        do {
            let req = try FCGIRequest(record: record, conn: self)
            self.curRequest = req
        } catch DataError.UnknownRole {
            // let unknown role error throw will tear down the connection
            return
        }
    }
    
    func handleData(record: Record) {
        guard let req = self.curRequest else {
            return
        }
        
        if record.contentLength > 0, let cntData = record.contentData {
            req.DATA = cntData
        }
    }
    
    func serveRequest(req: FCGIRequest) throws {
        let fcgiServer = self.server as! FCGIServer
        try fcgiServer.handleRequest(req)
        self.curRequest = nil
    }
}
