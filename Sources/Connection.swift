//
//  Connection.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol Connection{
    init(sock: Int32)
    func loop(server: Server)
}