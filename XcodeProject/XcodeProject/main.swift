//
//  main.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class MyApp: Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let writer = responder(status: "200", headers: ["Content-Type": "text/html", "My": "haha"])
        do {
            let form = "<form action=\"/armature/fdsdfdf\" method=\"POST\">" +
            "<input name=\"MAX_FILE_SIZE\" value=\"100000\" />" +
            "Choose a file to upload: <input name=\"uploadedfile\" type=\"file\" /><br/>" +
            "<input type=\"submit\" value=\"Upload File\" />" +
            "</form>"
            try writer("<!DOCTYPE html><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">from armature fastcgi</head><body>", nil)
            try writer(env.request.params.description, nil)
            try writer(form , nil)
            
            
            if env.CONTENT_LENGTH > 0 {
                try writer("===>" + String(env.CONTENT_LENGTH), nil)
                
                var input = [UInt8].init(count: Int(env.CONTENT_LENGTH), repeatedValue: 0)
                try env.STDIN.readInto(&input)
                if let cnt = String(bytes: input, encoding: NSUTF8StringEncoding) {
                    try writer(cnt, nil)
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
let server = SingleServer()
let app = MyApp()
server.debug = true
server.unix_socket_path = "/Users/tqtifnypmb/lighttpd/armature"
server.run(app)