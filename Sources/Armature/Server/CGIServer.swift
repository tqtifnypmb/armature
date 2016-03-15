//
//  CGIServer.swift
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

public final class CGIServer: Server {
    public var maxConnections: rlim_t = 0
    public var maxRequests: rlim_t = 0
    public var connectionType: Connection.Type = SingleConnection.self
    private var app: Application?
    
    public init() {
        
    }
    
    public func run(app: Application) {
        self.app = app
        
        let req = CGIRequest()
        do {
            try self.handleRequest(req)
        } catch {
            
        }
    }
    
    func handleRequest(req: Request) throws {
        guard let request = req as? CGIRequest else {
            return
        }
        
        guard let app = self.app else {
            return
        }
        let env = Environment(request: request)
        var headers: [String : String]?
        let respondWriter = { (output: String, error: String?) throws -> Void in
            if let headers = headers {
                var headersStr = ""
                for (name, value) in headers {
                    headersStr += name + ":" + value + "\r\n"
                }
                headersStr += "\r\n"
                try request.STDOUT.writeString(headersStr)
            }
            headers = nil
            
            try request.STDOUT.writeString(output)
            if let error = error {
                try request.STDERR.writeString(error)
            }
        }
        
        let responder = { (status: String, respHeaders: [String : String]) -> RespondWriter in
            headers = respHeaders
            headers!["Status"] = status
            
            return respondWriter
        }
        
        app.main(env, responder: responder)
        try request.finishHandling()
    }
}
