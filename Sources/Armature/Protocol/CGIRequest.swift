//
//  CGIRequest.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

final class CGIRequest: Request {
    var requestId: UInt16 = 0
    var STDIN: InputStorage
    var STDOUT: OutputStorage
    var STDERR: OutputStorage
    var DATA: [UInt8]?
    var params: [String : String] = [:] {
        didSet {
            if let cnt = params["CONTENT_LENGTH"], let cntLen = UInt16(cnt) {
                self.STDIN.contentLength = cntLen
            }
        }
    }
    var isRunning: Bool = false
    
    init() {
        self.STDIN = BufferedInputStorage(sock: STDIN_FILENO)
        self.STDOUT = BufferedOutputStorage(sock: STDOUT_FILENO, isErr: false)
        self.STDERR = BufferedOutputStorage(sock: STDERR_FILENO, isErr: true)
        self.params = NSProcessInfo.processInfo().environment
    }
    
    func finishHandling() throws {
        try self.STDOUT.flush()
        try self.STDERR.flush()
    }
    
    var isAborted: Bool {
        return false
    }
}
