//
//  UnitTests.swift
//  UnitTests
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import XCTest

class UnitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    /*
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    */
    
    func testLengthEncode() {
        let lenInBytes = Utils.encodeLength(511)
        XCTAssertEqual(511, Int(lenInBytes[0]) << 8 + Int(lenInBytes[1]))
    }
    
    func testNameValueParseEncode() {
        let toEncode = [
            
            "user_name" : "cvbncvn565765" , "password" : "123456789" ,      // short
            
            "abcsdklgjalsdghjksadghajksdghadjksghajksdghiwetyoiwtyioqwtyiwetyiwuetyiweutyiweutyiwuetywieutyiweutyeiwutsdgcx252352373346346346346363876589567167254545sdgsadgsdgasdgsdgsdgsdgsdgdgssdgsdgsdgsdgjhksdjghsdjkghsdkjgsadg" : "121235646ds89g7s89d7g8w9e7t.,./,/;l';l[]sdhgsdhfgkjsdhgkjsadhfgiuwetyiqweyut356834569893465930157290372727289346789hytjkasdhgjksabvksbvjksdabvajksdbvsdbvdksbvadsbvadjksbvsdghyuweyt78236587923658239569356232" ,
            "sldkfjsdgjwetqpwo" : "4454544=-0=890780678904583475726381412`" ,           // long

            "sdkfjasdkf" : ""                                                   // zero len
        ]
        let bytes = Utils.encodeNameValueData(toEncode)
        print(bytes)
        let pair = Utils.parseNameValueData(bytes)
        print(pair)
        var nPair: [String : String] = [:]
        for (key , value) in pair {
            nPair[key] = value
        }
        XCTAssertEqual(nPair, toEncode)
    }
    
    func testIsValidRemoteAddr() {
        
        var addrToBind = sockaddr_in()
        addrToBind.sin_family = sa_family_t(AF_INET)
        addrToBind.sin_port = in_port_t(16)
        addrToBind.sin_len = UInt8(sizeof(sockaddr_in))
        addrToBind.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        if 1 != inet_pton(AF_INET, "127.0.0.1", &addrToBind.sin_addr.s_addr) {
            print("f")
        }
        
        let toBind = UnitTests.socketaddr_cast(&addrToBind)
        XCTAssert( Utils.isValidRemoteAddr(["127.0.0.1"], to_check: &toBind.memory))

    }
    
    /*
    func testBufferedInputStorage() {
        let ser = Fast(addr: "", port: 10)
        let f = BufferedInputStorage(conn: SingleConnection(sock: 1, server: ser))
        f.contentLength = 34
        let buffer = [UInt8].init(count: 34, repeatedValue: 1)
        f.addData(buffer)
        var readBack = [UInt8].init(count: 34, repeatedValue: 0)
        do {
            try f.readInto(&readBack)
        } catch {
            
        }
        
        XCTAssertEqual(buffer, readBack)
    }
    */
    
    class func socketaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(p)
    }
}
