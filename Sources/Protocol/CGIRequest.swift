//
//  CGIRequest.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public class CGIRequest: Request {
    public var requestId: UInt16 = 0
    public var STDIN: InputStorage
    public var STDOUT: OutputStorage
    public var STDERR: OutputStorage
    public var DATA: [UInt8]?
    public var params: [String : String] = [:]
    
    init() {
        self.STDIN = BufferedInputStorage(sock: STDIN_FILENO)
        self.STDOUT = BufferedOutputStorage(sock: STDOUT_FILENO, isErr: false)
        self.STDERR = BufferedOutputStorage(sock: STDERR_FILENO, isErr: true)
        self.params = NSProcessInfo().environment
        if let cnt = params["CONTENT_LENGTH"], let cntLen = UInt16(cnt) {
            self.STDIN.contentLength = cntLen
        }
    }
    
    func finishHandling() throws {
        try self.STDOUT.flush()
        try self.STDERR.flush()
    }
}