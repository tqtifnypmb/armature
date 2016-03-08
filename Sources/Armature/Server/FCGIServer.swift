//
//  SingleServer.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/4/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class FCGIServer: Server {

    public var maxConnections: rlim_t
    public var maxRequests: rlim_t
    public var connectionType: Connection.Type = SingleConnection.self
    private var sock: Socket = Socket()
    private var app: Application?
    
    private let isThreaded: Bool
    private var connectionsQueue: NSOperationQueue!
    private var valid_server_addrs: [String]?
    
    public init(threaded: Bool = false) {

        var rLimit = rlimit()
        #if os(Linux)
            if getrlimit(Int32(RLIMIT_NOFILE.rawValue), &rLimit) != -1 {
                self.maxConnections = rLimit.rlim_cur
            } else {
                self.maxConnections = 100
            }
        #else
            if getrlimit(RLIMIT_NOFILE, &rLimit) != -1 {
                self.maxConnections = rLimit.rlim_cur
            } else {
                self.maxConnections = 100
            }
        #endif

        self.maxRequests = self.maxConnections
        self.isThreaded = threaded
        
        if threaded {
            self.connectionsQueue = NSOperationQueue()
        }
    }
    
    #if DEBUG
    
    public var debug = false;
    public var unix_socket_path = ""
    
    #endif
    
    public func run(app: Application) {
        self.app = app
        
        #if DEBUG
            
        if self.debug {
            do {    
                unlink(unix_socket_path)
                self.sock = try Socket.createBoundUnixSocket(unix_socket_path)
            } catch {
                print(error)
                return
            }
        }
        #else
        
        self.sock.socketFd = FCGI_LISTENSOCK_FILENO
            
        #endif
        
        defer {
            self.sock.closeSocket()
            
            if self.isThreaded {
                self.connectionsQueue.waitUntilAllOperationsAreFinished()
            }
        }
        
        if let web_server_addrs = NSProcessInfo.processInfo().environment["FCGI_WEB_SERVER_ADDRS"] {
            self.valid_server_addrs = web_server_addrs.componentsSeparatedByString(",")
        }
        
        while true {
            do {
                var remote_addr = sockaddr()
                var addr_len: socklen_t = 0
                
                // wait indefinitely
                try self.sock.waitForConnection()
                let conn = try self.sock.acceptConnection(&remote_addr, addrLen: &addr_len)
 
                guard Utils.isValidRemoteAddr(self.valid_server_addrs, to_check: &remote_addr) else {
                        continue
                }
                
                let connection = self.connectionType.init(sock: conn, server: self)
                
                if self.isThreaded {
                    self.connectionsQueue.addOperationWithBlock() {
                        connection.loop(false)
                    }
                } else {
                    connection.loop(false)
                }
            } catch {
                print(error)
                break
            }
        }
    }
    
    #if DEBUG
    public func forceStop() {
        self.sock.closeSocket()
    }
    #endif
    
    public func handleRequest(req: Request) throws {
        guard let request = req as? FCGIRequest else {
            return
        }

        request.setRunning()
        
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
