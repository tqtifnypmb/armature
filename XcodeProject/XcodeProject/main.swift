//
//  main.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

print("Hello, World!")

class MyApp: Application {
    func main(env: Environment, respondHeaders: RespondHeaders) -> CustomStringConvertible? {
        print("App runing")
        return nil
    }
}

let server = DebugServer(addr: "127.0.0.1", port: 9999)
let app = MyApp()
server.run(app)