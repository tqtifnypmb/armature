//
//  Multi_Connections.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/7/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import XCTest

var results: [UInt16: String] = [:]
class MyApp2: Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let writer = responder(status: "200", headers: ["Content-Type": "text/html"])
        do {
            var result = "Status:200\r\nContent-Type:text/html\r\n\r\n" + env.request.params.description
            try writer(env.request.params.description, nil)
            
            // Read stdin
            if env.CONTENT_LENGTH > 0 {
                var inputData = [UInt8].init(count: Int(env.CONTENT_LENGTH), repeatedValue: 0)
                try env.STDIN.readInto(&inputData)
                let inputStr = String(bytes: inputData, encoding: NSUTF8StringEncoding)!
                result += inputStr
                try writer(inputStr, nil)
            }
            
            // Read Data
            if let data = env.DATA {
                let dataStr = String(bytes: data, encoding: NSUTF8StringEncoding)!
                result += dataStr
                try writer(dataStr, nil)
            }
            results[env.request.requestId] = result
            
        } catch {
            // FIXME
            assert(false)
        }
        return 0
    }
}

class Multi_Connections: XCTestCase {

    var server: FCGIServer!
    var STDINLen = 0
    var id: UInt16 = 1
    let queue = NSOperationQueue()
    
    override func setUp() {
        super.setUp()
        
        server = FCGIServer(threaded: true)
        let app = MyApp2()
        
        server.debug = true
        server.unix_socket_path = "/Users/tqtifnypmb/lighttpd/armature"
        server.maxConnections = 100
        server.maxRequests = 100
        server.connectionType = MultiplexConnection.self
        
        queue.addOperationWithBlock() {
            self.server.run(app)
        }
        // Make sure server runs first
        sleep(1)
    }
    
    override func tearDown() {
        self.server.forceStop()
        
        // Make sure server has time to shutdown
        queue.waitUntilAllOperationsAreFinished()
        
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testMultiConnections() {
        queue.addOperationWithBlock() {
            self.sendRecordsAndCheckResult([self.begin_request, self.params, self.emptyParams], special_result: results[1])
        }

        sleep(1)
        queue.addOperationWithBlock() {
            self.STDINLen = 20
            self.id = 2
            self.sendRecordsAndCheckResult([self.begin_request, self.input, self.input, self.params, self.emptyParams], special_result: results[2])
        }
        
        sleep(2)
        print(results[1]! + "\n\n" + results[2]! )
        self.server.forceStop()
        queue.waitUntilAllOperationsAreFinished()
    }
    
    func testMultiplexReq() {
        self.STDINLen = 20
        self.id = 2
        let begin_request_2 = self.begin_request
        let input_2 = self.input
        let params_2 = self.params
        let empty_params_2 = self.emptyParams
        
        self.id = 1
        self.STDINLen = 30
        self.sendRecordsAndCheckResult([self.begin_request, self.input, begin_request_2, self.params, self.input, input_2, params_2, self.emptyParams, self.input, input_2, empty_params_2])
    }
    
    var emptyParams: Record {
        let emptyParams = Record()
        emptyParams.type = RecordType.PARAMS
        emptyParams.requestId = self.id
        emptyParams.contentLength = 0
        emptyParams.contentData = nil
        return emptyParams
    }
    
    var input: Record {
        let input = Record()
        input.type = RecordType.STDIN
        input.requestId = self.id
        input.contentLength = 10
        input.contentData = [UInt8].init(count: 10, repeatedValue: 1)
        return input
    }
    
    var begin_request: Record {
        let begin_req = Record()
        begin_req.type = RecordType.BEGIN_REQUEST
        begin_req.requestId = self.id
        let bytes: [UInt8] = [0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]
        begin_req.contentLength = UInt16(bytes.count)
        begin_req.contentData = bytes
        return begin_req
    }
    
    var params: Record {
        let params = Record()
        params.type = RecordType.PARAMS
        params.requestId = self.id
        let p = ["requestId": String(self.id), "Content_Length": String(self.STDINLen)]
        let b = Utils.encodeNameValueData(p)
        params.contentLength = UInt16(b.count)
        params.contentData = b
        return params
    }
    
    var data: Record {
        let d = Record()
        d.type = RecordType.DATA
        d.requestId = self.id
        d.contentLength = 20
        d.contentData = [UInt8].init(count: 20, repeatedValue: 10)
        return d
    }
    
    func sendRecordsAndCheckResult(records: [Record], special_result: String? = nil) {
        let client = SimpleClient()
        client.connectToServer(server.unix_socket_path)
        
        defer {
            close(client.socketFd)
        }
        
        do {
            for r in records {
                try r.writeTo(client.socketFd)
            }
            let ret = try Record.readFromSocket(client.socketFd)
            guard let cntData = ret.contentData else {
                XCTAssert(false, "Non result")
                return
            }
            let result = String(bytes: cntData, encoding: NSUTF8StringEncoding)
            
            if let sr = special_result {
                print("Special Type \(ret.type)")
                XCTAssertEqual(result, sr)
            } else {
                XCTAssertEqual(ret.type, RecordType.STDOUT)
                XCTAssertEqual(result, results[1]! + results[2]!)
            }
            
        } catch {
            XCTAssert(false, "Network error")
        }
    }
}
