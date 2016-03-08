//
//  CGIServer.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

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
