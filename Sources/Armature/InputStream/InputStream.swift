//
//  InputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// InputStream represent underlying network input, it should
// know nothing about protocol logic.
// InputStream exposes a python-file-object-like interface
// to users
protocol InputStream {
    init(sock: Int32)
    func readInto(inout buffer: [UInt8]) throws -> Int
    func readN(data: UnsafeMutablePointer<Void>, n: UInt32) throws
}
