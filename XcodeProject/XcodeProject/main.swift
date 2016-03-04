//
//  main.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class MyApp: Application {
    func main(env: Environment, respondHeaders: RespondHeaders) -> Int8 {
        let writer = respondHeaders(status: "200", headers: ["Content-Type": "text/html" , "Content-Length": "200"])
        do {
            try writer("<!DOCTYPE html><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">from armature fastcgi</head><body>This's my job", nil)
            if env.STDIN.contentLength > 0 {
                var buffer = [UInt8].init(count: Int(env.STDIN.contentLength), repeatedValue: 0)
                try env.STDIN.readInto(&buffer)
                if let str = String(bytes: buffer, encoding: NSUTF8StringEncoding) {
                    try writer(str, nil)
                }
            }
            try writer("</body></html>", nil)
        } catch {
            // FIXME
            assert(false)
        }
        return 0
    }
}

var addr = "/Users/tqtifnypmb/lighttpd/armature"
let server = DebugServer(addr: addr, port: 9999)
let app = MyApp()
server.run(app)
//assert(false)