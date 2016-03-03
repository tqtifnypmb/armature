//
//  Server.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation
/*
public protocol Server {
    var connectionType: Connection.Type {get set}
    var inputStreamType: InputStream.Type {get set}
    var outputStreamType: OutputStream.Type {get set}
    var maxConnections: UInt64 {get set}
    var maxRequests: UInt64 {get set}
    
    func run(app: Application)
    func handleRequest(request: Request)
}
*/

// Server responsible to :
//      - Handle errors thrown by connection
//        and application
//      - Consider request time out issues
//      - Consider signals handling issues
//      - Setup the whole environment
public protocol Server {
    func run(app: Application)
    
    // This funciton should be hidden from user
    // FIXME
    func handleRequest(request: Request) throws
    var maxConnections: UInt64 {get set}
    var maxRequests: UInt64 {get set}
}