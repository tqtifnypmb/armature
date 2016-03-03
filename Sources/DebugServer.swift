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
    public var connectionType: Connection.Type = SingleConnection.self
    public var inputStreamType: InputStream.Type = BufferedInputStream.self
    public var outputStreamType: OutputStream.Type = BufferedOutputStream.self
    private var sock: Socket = Socket()
    private var app: Application?
    
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
        self.app = app
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
                let connection = self.connectionType.init(sock: conn, server: self)
                connection.loop()
            } catch {
                print(error)
                break
            }
        }
    }
    
    public func handleRequest(request: Request) {
        guard let app = self.app else {
            return
        }
        let env = Environment(request: request)
        var headers: [String : String]?
        
        let respondWriter = { (output: String, error: String?) throws -> Void in
            if let headers = headers {
                let headerBytes = Utils.encodeNameValueData(headers)
                request.STDOUT.write(headerBytes)
            }
            headers = nil
            
            try request.STDOUT.writeString(output)
            if let error = error {
                try request.STDOUT.writeString(error)
            }
        }
        
        let respondHeaders = { (status: String, respHeaders: [String : String]) -> RespondWriter in
            headers = respHeaders
            return respondWriter
        }
        app.main(env, respondHeaders: respondHeaders)
    }
}