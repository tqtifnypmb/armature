//
//  Application.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/1/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//
import Foundation

public typealias Status = String
public typealias RespondWriter = (output: String, error: String?) throws -> Void
public typealias Responder = (status: Status, headers: [String : String]) -> RespondWriter

public protocol Application {
    // The main function as the application. It behave like C's main
    func main(env : Environment , responder : Responder) -> Int32
}