//
//  OutputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// OutputStream gives users a python-file-object-like
// interface. It's responsible to construct STDOUT record
// containing output data
public protocol OutputStream {
    init(sock: Int32)
    func write(inout data: [UInt8]) throws
}