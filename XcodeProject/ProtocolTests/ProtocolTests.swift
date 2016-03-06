//
//  ProtocolTests.swift
//  ProtocolTests
//
//  Created by Tqtifnypmb on 3/5/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import XCTest

var expect_result: String = ""
class MyApp: Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let writer = responder(status: "200", headers: ["Content-Type": "text/html"])
        do {
            expect_result = "Status:200\r\nContent-Type:text/html\r\n\r\n" + env.request.params.description
            try writer(env.request.params.description, nil)
            
            // Read stdin
            if env.CONTENT_LENGTH > 0 {
                var inputData = [UInt8].init(count: Int(env.CONTENT_LENGTH), repeatedValue: 0)
                try env.STDIN.readInto(&inputData)
                let inputStr = String(bytes: inputData, encoding: NSUTF8StringEncoding)!
                expect_result += inputStr
                try writer(inputStr, nil)
            }
            
            // Read Data
            if let data = env.DATA {
                let dataStr = String(bytes: data, encoding: NSUTF8StringEncoding)!
                expect_result += dataStr
                try writer(dataStr, nil)
            }
            
        } catch {
            // FIXME
            assert(false)
        }
        return 0
    }
}

class ProtocolTests: XCTestCase {

    var server: FCGIServer!
    var STDINLen = 0
    let queue = NSOperationQueue()
    override func setUp() {
        super.setUp()
        
        server = FCGIServer()
        let app = MyApp()
        
        server.debug = true
        server.unix_socket_path = "/Users/tqtifnypmb/lighttpd/armature"
        server.maxConnections = 100
        server.maxRequests = 100
        //server.connectionType = MultiplexConnection.self
        
        queue.addOperationWithBlock() {
            self.server.run(app)
        }
        // Make sure server runs first
        sleep(1)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        self.server.forceStop()
        
        // Make sure server has time to shutdown
        queue.waitUntilAllOperationsAreFinished()
        super.tearDown()
    }
    
    var emptyParams: Record {
        let emptyParams = Record()
        emptyParams.type = RecordType.PARAMS
        emptyParams.requestId = 1
        emptyParams.contentLength = 0
        emptyParams.contentData = nil
        return emptyParams
    }
    
    var input: Record {
        let input = Record()
        input.type = RecordType.STDIN
        input.requestId = 1
        input.contentLength = 10
        input.contentData = [UInt8].init(count: 10, repeatedValue: 1)
        return input
    }
    
    var begin_request: Record {
        let begin_req = Record()
        begin_req.type = RecordType.BEGIN_REQUEST
        begin_req.requestId = 1
        let bytes: [UInt8] = [0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]
        begin_req.contentLength = UInt16(bytes.count)
        begin_req.contentData = bytes
        return begin_req
    }
    
    var params: Record {
        let params = Record()
        params.type = RecordType.PARAMS
        params.requestId = 1
        let p = ["username": "basdlkfasdf", "Content_Length": String(self.STDINLen)]
        let b = Utils.encodeNameValueData(p)
        params.contentLength = UInt16(b.count)
        params.contentData = b
        return params
    }
    
    var data: Record {
        let d = Record()
        d.type = RecordType.DATA
        d.requestId = 1
        d.contentLength = 20
        d.contentData = [UInt8].init(count: 20, repeatedValue: 10)
        return d
    }
    
    func testGet_Value_Request() {
        let client = SimpleClient()
        client.connectToServer(server.unix_socket_path)
        
        defer {
            close(client.socketFd)
        }
        
        let get_value = Record()
        get_value.requestId = 0
        get_value.type = RecordType.GET_VALUE
        let query = ["FCGI_MAX_CONNS": "", "FCGI_MAX_REQS": "", "FCGI_MPXS_CONNS": ""]
        let queryBytes = Utils.encodeNameValueData(query)
        get_value.contentLength = UInt16(queryBytes.count)
        get_value.contentData = queryBytes
        
        do {
            try get_value.writeTo(client.socketFd)
            let get_value_result = try Record.readFromSocket(client.socketFd)
            let query_result = Utils.parseNameValueData(get_value_result.contentData!)
            
            let maxConn: UInt64 = 100
            let correct_result = ["FCGI_MAX_CONNS": String(maxConn), "FCGI_MAX_REQS": String(maxConn), "FCGI_MPXS_CONNS": "0"]
            XCTAssertEqual(correct_result, query_result)
        } catch {
            XCTAssert(false, "Network error")
        }
    }
    
    func testRequestWithoutSTDIN() {
        self.sendRecordsAndCheckResult([self.begin_request, self.params, self.emptyParams])
    }
    
    func testRequestSequentialSTDIN() {
        self.STDINLen = 20
        self.sendRecordsAndCheckResult([self.begin_request, self.input, self.input, self.params, self.emptyParams])
    }
    
    func testRequestRamdonSTDIN() {
        self.STDINLen = 30
        self.sendRecordsAndCheckResult([self.begin_request, self.input, self.params, self.input, self.emptyParams, self.input])
    }
    
    func testRequestWithData() {
        self.sendRecordsAndCheckResult([self.begin_request, self.params, self.data, self.emptyParams])
    }
    
    func testUnknownTypeRequest() {
        let r = self.begin_request
        r.type = RecordType.UNKNOWN_TYPE
        
        let result = [UInt8].init(arrayLiteral: r.type.rawValue, 0, 0, 0, 0, 0, 0, 0)
        let str = String(bytes: result, encoding: NSUTF8StringEncoding)
        self.sendRecordsAndCheckResult([r], special_result: str)
    }
    
    func testMultiplexReq() {
        self.STDINLen = 20
        let begin_request_2 = self.begin_request
        begin_request_2.requestId = 2
        
        let input_2 = self.input
        input_2.requestId = 2
        
        let params_2 = self.params
        params_2.requestId = 2
        
        let empty_params_2 = self.emptyParams
        empty_params_2.requestId = 2
        
        self.sendRecordsAndCheckResult([self.begin_request, self.input, begin_request_2, self.params, self.input, input_2, params_2, self.emptyParams, input_2, empty_params_2])
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
                XCTAssertEqual(result, expect_result)
            }
            
        } catch {
            XCTAssert(false, "Network error")
        }
    }
}

class SimpleClient {
    
    var socketFd: Int32 = 0
    func connectToServer(path: String) {
        
        var addrToBind = sockaddr_un()
        let pathLen = path.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        withUnsafeMutablePointer(&addrToBind.sun_path.0) { pathPtr in
            path.withCString {
                strncpy(pathPtr, $0, pathLen)
            }
        }
        
        let addrLen = sizeof(sockaddr_un) - sizeofValue(addrToBind.sun_path) + pathLen
        addrToBind.sun_family = sa_family_t(AF_UNIX)
        addrToBind.sun_len = UInt8(addrLen)
        
        let toConnect = socketaddr_cast(&addrToBind)
        self.socketFd = socket(Int32(AF_UNIX), SOCK_STREAM, 0)
        guard -1 != connect(socketFd, toConnect, socklen_t(addrLen)) else {
            print(Socket.getErrorDescription())
            return
        }
    }
    
    func socketaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(p)
    }
}

extension Record {
    class func readFromSocket(sock: Int32) throws -> Record {
        var buffer = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        try Utils.readN(sock, buffer: &buffer, n: UInt32(FCGI_HEADER_LEN))
        //try conn.readInto(&buffer)
        
        let record = Record()
        record.requestId = (UInt16(buffer[2]) << 8) + UInt16(buffer[3])
        record.contentLength = (UInt16(buffer[4]) << 8) + UInt16(buffer[5])
        let paddingLength = UInt32(buffer[6])
        
        if let type = RecordType(rawValue: buffer[1]) {
            record.type = type
        } else {
            // Ignore unsupport request type
            // FIXME log may be necessary
            try skip(sock, len: UInt32(record.contentLength) + paddingLength)
            throw DataError.InvalidData
        }
        
        if record.contentLength > 0 {
            var data = [UInt8].init(count: Int(record.contentLength), repeatedValue: 0)
            try Utils.readN(sock, buffer: &data, n: UInt32(record.contentLength))
            record.contentData = data
        }
        
        if paddingLength > 0 {
            try skip(sock, len: paddingLength)
        }
        
        return record
    }
    
    func writeTo(sock: Int32) throws {
        var paddingLength: UInt8 = 0
        if self.contentLength != 0 {
            paddingLength = UInt8(self.calPadding(self.contentLength, boundary: 8))
        }
        
        var heads = [UInt8].init(count: FCGI_HEADER_LEN, repeatedValue: 0)
        heads[0] = 1                                            // Version
        heads[1] = self.type.rawValue                           // Type
        heads[2] = UInt8(self.requestId >> UInt16(8))           // Request ID
        heads[3] = UInt8(self.requestId & 0xFF)                 // Request ID
        heads[4] = UInt8(self.contentLength >> 8)               // Content Length
        heads[5] = UInt8(self.contentLength & 0xFF)             // Content Length
        heads[6] = paddingLength                                // Paddign Length
        heads[7] = 0                                            // Reserve
        
        try Utils.writeN(sock, data: &heads, n: UInt32(FCGI_HEADER_LEN))
        if self.contentLength != 0 {
            try Utils.writeN(sock, data: &self.contentData!, n: UInt32(self.contentLength))
        }
        if paddingLength > 0 {
            var padding = [UInt8].init(count: Int(paddingLength), repeatedValue: 0)
            try Utils.writeN(sock, data: &padding, n: UInt32(paddingLength))
        }
    }
    
    private class func skip(sock: Int32, len: UInt32) throws {
        var ignore = [UInt8].init(count: Int(len), repeatedValue: 0)
        try Utils.readN(sock, buffer: &ignore, n: UInt32(len))
    }
    
    private func calPadding(n: UInt16, boundary: UInt16) -> UInt16 {
        guard n != 0 else {
            return boundary
        }
        return (~n + 1) & (boundary - 1)
    }
}