//
//  Server.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol Server {
    var maxConnections: rlim_t {get set}
    var maxRequests: rlim_t {get set}
    var connectionType: Connection.Type {get set}

    func run(app: Application)
}
