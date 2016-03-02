//
//  InputStream.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol InputStream {
    func readInto(buffer: UnsafeMutablePointer<UInt8>, bufferLen: Int) -> Int
    static func fromRecord(record: Record) -> InputStream
}