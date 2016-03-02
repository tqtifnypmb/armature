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
    
    // Standard request meta-variables
    // see [RFC 3875]
    var AUTH_TYPE: String?
    var CONTENT_LENGTH: UInt = 0
    var CONTENT_TYPE: String?
    var GATEWAY_INTERFACE: String?
    var PATH_INFO: String? = nil
    var PATH_TRANSLATED: String?
    var QUERY_STRING: String?
    var REMOTE_ADDR: String?
    var REMOTE_HOST: String?
    var REMOTE_IDENT: String?
    var REMOTE_USER: String?
    var REQUEST_MOTHOD: String?
    var SCRIPT_NAME: String?
    var SERVER_NAME: String?
    var SERVER_PORT: UInt16 = 0
    var SERVER_PROTOCOL: String?
    var SERVER_SOFTWARE: String?
    
    // Extra request meta-variables
    var extra: [String: String?] = [:]
    
    var STDIN: InputStream?
    var STDOUT: OutputStream?
    var STDERR: OutputStream?
    var DATA: [UInt8]?
    
    class func fromRecord(record: Record) throws -> Request {
        assert(record.type == .BEGIN_REQUEST)
        guard let cntData = record.contentData else {
            throw DataError.InvalidData
        }
        guard let role = Role(rawValue: UInt8(cntData[0] << 8 + cntData[1])) else {
            throw DataError.UnknownRole("Unknown role \(cntData[0] << 8 + cntData[1])")
        }
        let req = Request()
        req.requestId = record.requestId
        req.role = role
        req.flags = cntData[2]
        return req
    }
    
    func setParams(params: [String : String?]) {
        for (name , value) in params {
            switch name {
            case "AUTH_TYPE":
                self.AUTH_TYPE = value
                break
                
            case "CONTENT_LENGTH":
                if let value = value , let len = UInt(value) {
                    self.CONTENT_LENGTH = len
                }
                break
                
            case "CONTENT_TYPE":
                self.CONTENT_TYPE = value
                break
                
            case "GATEWAY_INTERFACE":
                self.GATEWAY_INTERFACE = value
                break
                
            case "PATH_INFO":
                self.PATH_INFO = value
                break
                
            case "PATH_TRANSLATED":
                self.PATH_TRANSLATED = value
                break
                
            case "QUERY_STRING":
                self.QUERY_STRING = value
                break
                
            case "REMOTE_ADDR":
                self.REMOTE_ADDR = value
                break
                
            case "REMOTE_HOST":
                self.REMOTE_HOST = value
                break
                
            case "REMOTE_IDENT":
                self.REMOTE_IDENT = value
                break
                
            case "REQUEST_METHOD":
                self.REQUEST_MOTHOD = value
                break
                
            case "SCRIPT_NAME":
                self.SCRIPT_NAME = value
                break
                
            case "SERVER_NAME":
                self.SERVER_NAME = value
                break
                
            case "SERVER_PORT":
                if let value = value , let port = UInt16(value) {
                    self.SERVER_PORT = port
                }
                break
                
            case "SERVER_PROTOCOL":
                self.SERVER_PROTOCOL = value
                break
                
            case "SERVER_SOFTWARE":
                self.SERVER_SOFTWARE = value
                break
                
            default:
                self.extra[name] = value
                break
            }
        }
    }
}