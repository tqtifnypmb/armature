//
//  Request.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public protocol Request {
    var STDIN: InputStorage         {get set}
    var STDOUT: OutputStorage       {get set}
    var STDERR: OutputStorage       {get set}
    var DATA: [UInt8]?              {get set}
    var params: [String : String]   {get set}
    var requestId: UInt16           {get set}
    var isAborted: Bool             {get}
    var isRunning: Bool             {get}
}