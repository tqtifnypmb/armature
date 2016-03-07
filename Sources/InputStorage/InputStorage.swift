//
//  Storage.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol InputStorage {
    init(conn: Connection)
    init(sock: Int32)
    func readInto(inout buffer: [UInt8]) throws -> Int
    func addData(data: [UInt8])
    var contentLength: UInt16 {get set}
}