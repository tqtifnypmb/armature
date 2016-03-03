//
//  Connection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol Connection{
    var server: Server {get}
    init(sock: Int32, server: Server)
    func loop()
}