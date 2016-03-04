//
//  Environment.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class Environment {
    
    // Standard request meta-variables
    // see [RFC 3875]
    var AUTH_TYPE: String? {
        return self.request.params["AUTH_TYPE"]
    }
    
    var CONTENT_LENGTH: UInt {
        if let value = self.request.params["CONTENT_LENGTH"] , let len = UInt(value) {
            return len
        } else {
            return 0
        }
    }
    
    var CONTENT_TYPE: String? {
        return self.request.params["CONTENT_TYPE"]
    }
    
    var GATEWAY_INTERFACE: String? {
        return self.request.params["GATEWAY_INTERFACE"]
    }
    
    var PATH_INFO: String? {
        return self.request.params["PATH_INFO"]
    }
    
    var PATH_TRANSLATED: String? {
        return self.request.params["PATH_TRANSLATED"]
    }
    
    var QUERY_STRING: String? {
        return self.request.params["QUERY_STRING"]
    }
    
    var REMOTE_ADDR: String? {
        return self.request.params["REMOTE_ADDR"]
    }
    
    var REMOTE_HOST: String? {
        return self.request.params["REMOTE_HOST"]
    }
    
    var REMOTE_IDENT: String? {
        return self.request.params["REMOTE_IDENT"]
    }
    
    var REMOTE_USER: String? {
        return self.request.params["REMOTE_USER"]
    }
    
    var REQUEST_MOTHOD: String? {
        return self.request.params["REQUEST_MOTHOD"]
    }
    
    var SCRIPT_NAME: String? {
        return self.request.params["SCRIPT_NAME"]
    }
    
    var SERVER_NAME: String? {
        return self.request.params["SERVER_NAME"]
    }
    
    var SERVER_PORT: UInt16 {
        if let value = self.request.params["SERVER_PORT"] , let port = UInt16(value) {
            return port
        } else {
            return 0
        }
    }
    
    var SERVER_PROTOCOL: String? {
        return self.request.params["SERVER_PROTOCOL"]
    }
    
    var SERVER_SOFTWARE: String? {
        return self.request.params["SERVER_SOFTWARE"]
    }
    
    var STDIN: InputStorage {
        return self.request.STDIN
    }
    /*
    var STDOUT: OutputStream? {
        return self.request.STDOUT
    }
    
    var STDERR: OutputStream? {
        return self.request.STDERR
    }
    */
    var DATA: [UInt8]? {
        return self.request.DATA
    }
    
    subscript(key: String) -> String? {
        return self.request.params[key]
    }
    
    let request: Request
    init(request: Request) {
        self.request = request
    }
}