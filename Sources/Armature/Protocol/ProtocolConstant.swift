//
//  ProtocolConstant.swift
//  Armature
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 tqtifnypmb
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import Foundation

enum RecordType: UInt8 {
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

enum Role: UInt16 {
    case RESPONDER = 1
    case FILTER = 2
    case AUTHORIZER = 3
}

enum ProtocolStatus: UInt8 {
    case REQUEST_COMPLETE = 0
    case CANT_MPX_CONN = 1
    case OVERLOADED = 2
    case UNKNOWN_ROLE = 3
}

let FCGI_MAX_CONNS = "FCGI_MAX_CONNS"
let FCGI_MAX_REQS = "FCGI_MAX_REQS"
let FCGI_MPXS_CONNS = "FCGI_MPXS_CONNS"

let FCGI_HEADER_LEN = 8

let FCGI_KEEP_CONN: UInt8 = 1

let FCGI_LISTENSOCK_FILENO: Int32 = 0
