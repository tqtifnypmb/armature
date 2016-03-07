//
//  OuputStorage.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol OutputStorage {
    init(conn: Connection, reqId: UInt16, isErr: Bool)
    init(sock: Int32, isErr: Bool)
    func write(data: [UInt8]) throws
    func writeString(str: String) throws
    func writeEOF() throws
    func flush() throws
}