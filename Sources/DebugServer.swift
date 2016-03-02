//
//  SimpleServer.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class DebugServer : Server{
    
    var addr: String
    var port: UInt16
    public var maxConnections: UInt64
    public var maxRequests: UInt64
    public var connection: Connection.Type = SingleConnection.self
    private var sock: Socket = Socket()
    
    init(addr: String , port: UInt16) {
        self.addr = addr
        self.port = port
        
        var rLimit = rlimit()
        if getrlimit(RLIMIT_NOFILE, &rLimit) != -1 {
            self.maxConnections = rLimit.rlim_cur
        } else {
            self.maxConnections = 100
        }
        self.maxRequests = self.maxConnections
    }
    
    public func run(app: Application) {
        do {
            sock = try Socket.createBoundTcpSocket(self.addr, port: self.port)
        } catch {
            // FIXME: Log here
            print(error)
        }
        
        defer {
            self.sock.closeSocket()
        }
        
        while true {
            do {
                let conn = try self.sock.acceptConnection()
                let connection = self.connection.init(sock: conn)
                connection.loop(self)
            } catch {
                print(error)
                break
            }
        }
    }
    
    public func handleRequest(request: Request) {
    }
}