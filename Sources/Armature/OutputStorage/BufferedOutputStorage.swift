//
//  BufferedOutputStorage.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

final class BufferedOutputStorage: OutputStorage {
    
    // This is number is from flup
    private let maxBuffer = 8192
    private var buffer: [UInt8] = []
    private let isErr: Bool
    private var connection: Connection!
    private let requestId: UInt16
    private var needEOF = false
    
    required init(conn: Connection, reqId: UInt16, isErr: Bool) {
        self.connection = conn
        self.isErr = isErr
        self.requestId = reqId
    }
    
    required init(sock: Int32, isErr: Bool) {
        self.connection = RawConnection(sock: sock)
        self.isErr = isErr
        self.requestId = 0
    }
    
    func write(data: [UInt8]) throws {
        self.needEOF = true
        self.buffer.appendContentsOf(data)
        if self.buffer.count >= self.maxBuffer {
            try self.buildRecord().writeTo(self.connection)
            self.buffer.removeAll(keepCapacity: true)
        }
    }
    
    func writeString(str: String) throws {
        var buffer = [UInt8].init(count: str.lengthOfBytesUsingEncoding(NSUTF8StringEncoding), repeatedValue: 0)
        str.toBytes(&buffer)
        try self.write(buffer)
    }
    
    func flush() throws {
        guard self.buffer.count > 0 else {
            return
        }
        try self.buildRecord().writeTo(self.connection)
        self.buffer.removeAll(keepCapacity: true)
    }
    
    func writeEOF() throws {
        guard self.needEOF else {
            return
        }
        
        let type = self.isErr == true ? RecordType.STDERR: RecordType.STDOUT
        let eof = Record.createEOFRecord(self.requestId, type: type)
        try eof.writeTo(self.connection)
    }
    
    private func buildRecord() -> Record {
        let record = Record()
        record.requestId = self.requestId
        record.type = (self.isErr ? RecordType.STDERR : RecordType.STDOUT)
        record.contentLength = UInt16(self.buffer.count)
        record.contentData = self.buffer
        return record
    }
}
