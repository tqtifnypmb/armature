//
//  SingleConnection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class SingleConnection: Connection {
    let sock: Int32
    var stop = false
    var request: Request?
    public var server: Server
    
    required public init(sock: Int32, server: Server) {
        self.sock = sock
        self.server = server
    }
    
    public func loop() {
        while !stop {
            do {
                try processInput()
            } catch {
                // All data processing error 
                // should be handled here
                print(error)
                break
            }
        }
    }
    
    private func processInput() throws {
        guard let record = try Record.readFrom(self.sock) else {
            return
        }
        
        switch record.type {
        case .GET_VALUE:
            try self.handleGetValue(record)
            break
            
        case .ABORT_REQUEST:
            self.handleAbortRequest(record)
            break
            
        case .PARAMS:
            self.handleParams(record)
            break
            
        case .STDIN:
            self.handleStdIn(record)
            break
            
        case .BEGIN_REQUEST:
            self.handleBeginRequest(record)
            break
            
        default:
            // Invalid record type
            // Ignore it
            // FIXME: do some log here?
            break
        }
    }
    
    private func handleGetValue(record: Record) throws {
        guard record.contentLength != 0 , let cntData = record.contentData else {
            return
        }
        
        let ret = Record()
        ret.type = RecordType.GET_VALUE_RESULT
        ret.requestId = 0
        let query = Utils.parseNameValueData(cntData)
        var result: [String : String] = [:]
        
        for name in query.keys {
            switch name {
            case FCGI_MAX_CONNS:
                result[name] = String(self.server.maxConnections)
                break
                
            case FCGI_MAX_REQS:
                result[name] = String(self.server.maxRequests)
                break
                
            case FCGI_MPXS_CONNS:
                result[name] = String(0)
                break
                
            default:
                // Unknown query
                break
            }
        }
        ret.contentData = Utils.encodeNameValueData(result)
        ret.contentLength = UInt16(ret.contentData!.count)
        try ret.writeTo(self.sock)
    }
    
    private func handleAbortRequest(record: Record) {
    }
    
    private func handleParams(record: Record) {
        guard let req = self.request else {
            // Current request isn't valid maybe something wrong
            // in data sent from server
            return
        }
        
        guard record.contentLength != 0 , let cntData = record.contentData else {
            // A empty params is sent
            // tick the request
            self.server.handleRequest(req)
            self.request = nil
            return
        }
        
        let params = Utils.parseNameValueData(cntData)
        req.setParams(params)
    }
    
    private func handleStdIn(record: Record) {
        guard let req = self.request else {
            // Current request isn't valid maybe something wrong
            // in data sent from server
            return
        }
        
        if record.contentLength > 0, let cntData = record.contentData {
            req.STDIN.addData(cntData)
        }
    }
    
    private func handleBeginRequest(record: Record) {
        do {
            let req = try Request.fromRecord(record, conn: self)
            self.request = req
        } catch {
            // Can't create request from received record
            print(error)
            return
        }
    }
}