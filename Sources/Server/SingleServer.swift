//
//  SingleServer.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/4/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class SingleServer: Server {

    public var maxConnections: UInt64
    public var maxRequests: UInt64
    public var connectionType: Connection.Type = SingleConnection.self
    private var sock: Socket = Socket()
    private var app: Application?
    
    init() {
        var rLimit = rlimit()
        if getrlimit(RLIMIT_NOFILE, &rLimit) != -1 {
            self.maxConnections = rLimit.rlim_cur
        } else {
            self.maxConnections = 100
        }
        self.maxRequests = self.maxConnections
    }
    
    public var debug = false;
    
    public func run(app: Application) {
        self.app = app
        
        if self.debug {
            do {
                unlink("/Users/tqtifnypmb/lighttpd/armature")
                let path = "/Users/tqtifnypmb/lighttpd/armature"
                self.sock = try Socket.createBoundUnixSocket(path)
            } catch {
                print(error)
                assert(false)
            }
        } else {
            self.sock = Socket()
            self.sock.socketFd = 0
        }
        
        defer {
            self.sock.closeSocket()
        }
        
        while true {
            do {
                // wait indefinitely
                try self.sock.waitForConnection(nil)
                let conn = try self.sock.acceptConnection()
                let connection = self.connectionType.init(sock: conn, server: self)
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
                    connection.loop(false)
                }
            } catch {
                print(error)
                break
            }
        }
    }
    
    public func handleRequest(request: Request) throws {
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
        
        let appStatus = app.main(env, responder: responder)
        try request.finishHandling(appStatus, protoStatus: ProtocolStatus.REQUEST_COMPLETE)
    }
}