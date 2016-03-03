//
//  main.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class MyApp: Application {
    func main(env: Environment, respondHeaders: RespondHeaders) -> UInt8 {
        let writer = respondHeaders(status: "301", headers: ["Content-Type": "text/html" , "Content-Length": "50"])
        do {
            //try writer(env.request.params.description, nil)
            try writer("<html><head>from armature fastcgi</head><body>This's my job</body></html>", nil)
        } catch {
            // FIXME
        }
        return 0
    }
}

var addr = "/Users/tqtifnypmb/lighttpd/armature"
let server = DebugServer(addr: addr, port: 9999)
let app = MyApp()
server.run(app)
//assert(false)