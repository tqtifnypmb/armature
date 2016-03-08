//
//  Exception.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

public enum SocketError: ErrorType {
    case UnableToCreateSocket(String)
    case UnableToBindSocket(String)
    case UnableToListenSocket(String)
    case UnableToSetSocketOption(String)
    case AcceptFailed(String)
    case SelectFailed(String)
    case ReadFailed(String)
}


public enum DataError: ErrorType {
    case UnknownRole(String)
    case InvalidData
}
