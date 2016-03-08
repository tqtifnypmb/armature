//
//  main.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation
import Armature

class MyApp: Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let writer = responder(status: "200", headers: ["Content-Type": "text/html", "My": "haha"])
        do {
            let form = "<form action=\"/cgi-bin/XcodeProject.swift\" method=\"POST\">" +
            "<input name=\"MAX_FILE_SIZE\" value=\"100000\" />" +
            "Choose a file to upload: <input name=\"uploadedfile\" type=\"file\" /><br/>" +
            "<input type=\"submit\" value=\"Upload File\" />" +
            "</form>"
            try writer(output: "<!DOCTYPE html><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">from armature fastcgi</head><body>", error: nil)
            try writer(output: env.request.params.description, error: nil)
            try writer(output: form , error: nil)
            
            
            if env.CONTENT_LENGTH > 0 {
                try writer(output: "===>" + String(env.CONTENT_LENGTH), error: nil)
                
                var input = [UInt8].init(count: Int(env.CONTENT_LENGTH), repeatedValue: 0)
                try env.STDIN.readInto(&input)
                if let cnt = String(bytes: input, encoding: NSUTF8StringEncoding) {
                    try writer(output: cnt, error: nil)
                }
            }
            
            try writer(output: "</error: body></html>", error: nil)
            
        } catch {
            // FIXME:
            assert(false)
        }
        return 0
    }
}

let server = FCGIServer()
//let server = CGIServer()
let app = MyApp()
server.run(app)
assert(false)
