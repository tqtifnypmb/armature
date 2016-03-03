//
//  Request.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

internal enum DataError: ErrorType {
    case UnknownRole(String)
    case InvalidData
}

public class Request {
    var requestId: UInt16 = 0
    var role: Role = .RESPONDER
    var flags: UInt8 = 0
    
    var STDIN: InputStream
    var STDOUT: OutputStream
    var STDERR: OutputStream
    var DATA: [UInt8]?
    var params: [String : String] = [:]
    var connection: Connection!
    
    class func fromRecord(record: Record, conn: Connection) throws -> Request {
        assert(record.type == .BEGIN_REQUEST)
        guard let cntData = record.contentData else {
            throw DataError.InvalidData
        }
        guard let role = Role(rawValue: UInt8(cntData[0] << 8 + cntData[1])) else {
            throw DataError.UnknownRole("Unknown role \(cntData[0] << 8 + cntData[1])")
        }
        let req = Request(input: conn.server.inputStreamType.init(), output: conn.server.outputStreamType.init(), err: conn.server.outputStreamType.init())
        req.requestId = record.requestId
        req.role = role
        req.flags = cntData[2]
        req.connection = conn
        return req
    }
    
    init(input: InputStream, output: OutputStream, err: OutputStream) {
        self.STDIN = input
        self.STDOUT = output
        self.STDERR = err
    }
    
    func setParams(params: [String : String?]) {
        // drop all items that without value
        for (name , value) in params {
            if let value = value {
                self.params.updateValue(name, forKey: value)
            }
        }
    }
}