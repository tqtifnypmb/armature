//
//  OutputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

// OutputStream represent underlying network output, it should
// know nothing about protocol logic.
// OutputStream exposes a python-file-object-like interface
// to users
protocol OutputStream {
    init(sock: Int32)
    func write(inout data: [UInt8]) throws
}
