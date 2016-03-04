//
//  InputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// InputStream gives a python-file-object-like interface
// to users
public protocol InputStream {
    init(sock: Int32)
    func readInto(inout buffer: [UInt8]) throws -> Int
    func readN(data: UnsafeMutablePointer<Void>, n: UInt32) throws
}