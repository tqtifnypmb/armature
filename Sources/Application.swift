//
//  Application.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//
import Foundation

public typealias Environment = [String : String]
public typealias Status = String
public typealias RespondHeaders = (Status , [String : String]) -> Void

public protocol Application {
    func main(env : Environment , respondHeaders : RespondHeaders) -> CustomStringConvertible
}