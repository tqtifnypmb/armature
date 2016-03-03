//
//  InputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol InputStream {
    init()
    func readInto(inout buffer: [UInt8]) -> Int
    func addData(dataToAdd: [UInt8])
}