//
//  ProtocolConstant.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

internal enum RecordType: UInt8 {
    case BEGIN_REQUEST = 1
    case ABORT_REQUEST = 2
    case END_REQUEST = 3
    case PARAMS = 4
    case STDIN = 5
    case STDOUT = 6
    case STDERR = 7
    case DATA = 8
    case GET_VALUE = 9
    case GET_VALUE_RESULT = 10
    case UNKNOWN_TYPE = 11
}

internal enum Role: UInt16 {
    case RESPONDER = 1
    case FILTER = 2
    case AUTHORIZER = 3
}

internal enum ProtocolStatus: UInt8 {
    case REQUEST_COMPLETE = 0
    case CANT_MPX_CONN = 1
    case OVERLOADED = 2
    case UNKNOWN_ROLE = 3
}

let FCGI_MAX_CONNS = "FCGI_MAX_CONNS"
let FCGI_MAX_REQS = "FCGI_MAX_REQS"
let FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS"

let FCGI_HEADER_LEN = 8