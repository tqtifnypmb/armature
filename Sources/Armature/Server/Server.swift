//
//  Server.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// Server responsible to :
//      - Handle errors thrown by connection
//        and application
//      - Consider request time out issues
//      - Consider signals handling issues
//      - Setup the whole environment
public protocol Server {
    
    func run(app: Application)
    
    // FIXME: This funciton should be hidden from user
    func handleRequest(request: Request) throws
    var maxConnections: rlim_t {get set}
    var maxRequests: rlim_t {get set}
    var connectionType: Connection.Type {get set}
}
