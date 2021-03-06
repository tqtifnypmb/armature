//
//  FCGIRequest.swift
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
