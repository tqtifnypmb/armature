//
//  Connection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// Connection connect server to underlying network.
// It contains/handle FastCGI/CGI protocol logic as well
// All errors from network or data coming from network
// should be caught here. 
public protocol Connection {
    init(sock: Int32, server: Server)
    func loop(once: Bool)
    func halt()
    func readInto(inout buffer: [UInt8]) throws -> Int
    func write(inout data: [UInt8]) throws
}
