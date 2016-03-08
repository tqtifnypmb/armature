//
//  FCGIRequest.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

final class FCGIRequest: Request {
    var requestId: UInt16 = 0
    var role: Role = .RESPONDER
    var flags: UInt8 = 0
    var connection: Connection!
    
    var STDIN: InputStorage
    var STDOUT: OutputStorage
    var STDERR: OutputStorage
    var DATA: [UInt8]?
    var isRunning: Bool = false
    
    private var aborted = false
    var params: [String : String] = [:] {
        didSet {
            if let cnt = params["CONTENT_LENGTH"], let cntLen = UInt16(cnt) {
                self.STDIN.contentLength = cntLen
            }
        }
    }
    
    init(record: Record, conn: Connection) throws {
        assert(record.type == .BEGIN_REQUEST)
        
        self.connection = conn
        self.STDIN = BufferedInputStorage(conn: self.connection)
        self.STDOUT = BufferedOutputStorage(conn: self.connection, reqId: record.requestId, isErr: false)
        self.STDERR = BufferedOutputStorage(conn: self.connection, reqId: record.requestId, isErr: true)
        self.requestId = record.requestId
        
        guard let cntData = record.contentData else {
            throw DataError.InvalidData
        }
        self.flags = cntData[2]
        
        guard let role = Role(rawValue: UInt16(cntData[0]) << 8 + UInt16(cntData[1])) else {
            // Unknown role
            try self.finishHandling(0, protoStatus: ProtocolStatus.UNKNOWN_ROLE)
            
            // throw a error to finish whole handling process
            throw DataError.UnknownRole("Unknonwn role \(UInt16(cntData[0]) << 8 + UInt16(cntData[1]))")
        }
        self.role = role
    }
    
    func abort() {
        self.aborted = true
    }
    
    func setRunning() {
        self.isRunning = true
    }
    
    var isAborted: Bool {
        return self.aborted
    }
    
    func finishHandling(appStatus: Int32, protoStatus: ProtocolStatus) throws {
        try self.STDOUT.flush()
        try self.STDERR.flush()
        try self.STDOUT.writeEOF()
        try self.STDERR.writeEOF()
        
        let completeRecord = Record()
        completeRecord.requestId = self.requestId
        completeRecord.type = RecordType.END_REQUEST
        
        var statusBytes = Utils.encodeAppStatus(appStatus)
        statusBytes.appendContentsOf([protoStatus.rawValue])
        completeRecord.contentData = statusBytes
        completeRecord.contentLength = UInt16(statusBytes.count)
        try completeRecord.writeTo(self.connection)
        try self.STDOUT.flush()
        try self.STDERR.flush()
        
        if self.flags & FCGI_KEEP_CONN == 0 {
            self.connection.halt()
        }
    }
}
