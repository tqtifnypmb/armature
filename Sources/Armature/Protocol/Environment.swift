//
//  Environment.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public final class Environment {
    
    // Standard request meta-variables
    // see [RFC 3875]
    public var AUTH_TYPE: String? {
        return self.request.params["AUTH_TYPE"]
    }
    
    public var CONTENT_LENGTH: UInt {
        if let value = self.request.params["CONTENT_LENGTH"] , let len = UInt(value) {
            return len
        } else {
            return 0
        }
    }
    
    public var CONTENT_TYPE: String? {
        return self.request.params["CONTENT_TYPE"]
    }
    
    public var GATEWAY_INTERFACE: String? {
        return self.request.params["GATEWAY_INTERFACE"]
    }
    
    public var PATH_INFO: String? {
        return self.request.params["PATH_INFO"]
    }
    
    public var PATH_TRANSLATED: String? {
        return self.request.params["PATH_TRANSLATED"]
    }
    
    public var QUERY_STRING: String? {
        return self.request.params["QUERY_STRING"]
    }
    
    public var REMOTE_ADDR: String? {
        return self.request.params["REMOTE_ADDR"]
    }
    
    public var REMOTE_HOST: String? {
        return self.request.params["REMOTE_HOST"]
    }
    
    public var REMOTE_IDENT: String? {
        return self.request.params["REMOTE_IDENT"]
    }
    
    public var REMOTE_USER: String? {
        return self.request.params["REMOTE_USER"]
    }
    
    public var REQUEST_MOTHOD: String? {
        return self.request.params["REQUEST_MOTHOD"]
    }
    
    public var SCRIPT_NAME: String? {
        return self.request.params["SCRIPT_NAME"]
    }
    
    public var SERVER_NAME: String? {
        return self.request.params["SERVER_NAME"]
    }
    
    public var SERVER_PORT: UInt16 {
        if let value = self.request.params["SERVER_PORT"] , let port = UInt16(value) {
            return port
        } else {
            return 0
        }
    }
    
    public var SERVER_PROTOCOL: String? {
        return self.request.params["SERVER_PROTOCOL"]
    }
    
    public var SERVER_SOFTWARE: String? {
        return self.request.params["SERVER_SOFTWARE"]
    }
    
    public var STDIN: InputStorage {
        return self.request.STDIN
    }

    public var DATA: [UInt8]? {
        return self.request.DATA
    }
    
    public var is_request_aborted: Bool {
        return self.request.isAborted
    }
    
    public subscript(key: String) -> String? {
        return self.request.params[key]
    }
    
    public func extra(key: String) -> String? {
        return self[key]
    }
    
    public let request: Request
    init(request: Request) {
        self.request = request
    }
}
