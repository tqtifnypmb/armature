//
//  Application.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//
import Foundation

public typealias Status = String
public typealias RespondWriter = (String, String) throws -> Void
public typealias RespondHeaders = (Status , [String : String]) -> RespondWriter

public protocol Application {
    func main(env : Environment , respondHeaders : RespondHeaders) -> CustomStringConvertible?
}