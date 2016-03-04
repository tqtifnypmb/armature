//
//  Connection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// Connection responsible to :
//     - Input/Output
//     - Construct request
//     - Deliver request to server
//     - throws all socket error and 
//       data error to server
public protocol Connection {
    init(sock: Int32, server: Server)
    func loop(once: Bool)
    func halt()
    
    var sock: Int32 {get}
    var inputStreamType: InputStream.Type {get set}
    var outputStreamType: OutputStream.Type {get set}
    
    func readInto(inout buffer: [UInt8]) throws -> Int
    func write(inout data: [UInt8]) throws
    func abortRequest(reqId: UInt16) throws
}