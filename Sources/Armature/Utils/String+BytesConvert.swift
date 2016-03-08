//
//  String+BytesConvert.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

extension String {
    func toBytes(inout buffer: [UInt8]) -> Bool {
        return self.getBytes(&buffer,
            maxLength: buffer.capacity,
            usedLength: nil,
            encoding: NSUTF8StringEncoding,
            options: .AllowLossy,
            range: Range(start: self.startIndex, end: self.endIndex),
            remainingRange: nil)
    }
}
