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
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
        let toEncode = ["user_name" : "cvbncvn565765" , "password" : "123456789" , "abcsdklgjalsdghjksadghajksdghadjksghajksdghiwetyoiwtyioqwtyiwetyiwuetyiweutyiweutyiwuetywieutyiweutyeiwutsdgcx252352373346346346346363876589567167254545sdgsadgsdgasdgsdgsdgsdgsdgdgssdgsdgsdgsdgjhksdjghsdjkghsdkjgsadg" : "121235646ds89g7s89d7g8w9e7t.,./,/;l';l[]sdhgsdhfgkjsdhgkjsadhfgiuwetyiqweyut356834569893465930157290372727289346789hytjkasdhgjksabvksbvjksdabvajksdbvsdbvdksbvadsbvadjksbvsdghyuweyt78236587923658239569356232" , "sldkfjsdgjwetqpwo" : "4454544=-0=890780678904583475726381412`"]
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
}
