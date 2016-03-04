//
//  main.swift
//  SimpleClient
//
//  Created by Tqtifnypmb on 3/3/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

class SimpleClient {
    
    var socketFd: Int32 = 0
    func connectTo(ip: String, port: UInt16) {
        
        /*
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr = in_addr(s_addr: inet_addr(ip))
        addr.sin_len = UInt8(sizeof(sockaddr_in))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        let toConnect = self.socketaddr_cast(&addr)
        
        self.socketFd = socket(Int32(AF_INET), SOCK_STREAM, 0)
        connect(socketFd, toConnect, socklen_t(sizeof(sockaddr_in)))
        */
        var addrToBind = sockaddr_un()
        
        let path = "/Users/tqtifnypmb/lighttpd/armature"
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

let begin_req = Record()
begin_req.type = RecordType.BEGIN_REQUEST
begin_req.requestId = 1
let bytes: [UInt8] = [0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00]
//let bytes = Utils.encodeNameValueData(request)
//print(bytes)
begin_req.contentLength = UInt16(bytes.count)
begin_req.contentData = bytes

let params = Record()
params.type = RecordType.PARAMS
params.requestId = 1
let p = ["username": "basdlkfasdf"]
let b = Utils.encodeNameValueData(p)
params.contentLength = UInt16(b.count)
params.contentData = b

let emptyParams = Record()
emptyParams.type = RecordType.PARAMS
emptyParams.requestId = 1
emptyParams.contentLength = 0
emptyParams.contentData = nil

let client = SimpleClient()
client.connectTo("127.0.0.1", port: 9999)
try begin_req.writeTo(client.socketFd)
try params.writeTo(client.socketFd)
try emptyParams.writeTo(client.socketFd)

var buffer = [UInt8].init(count: 8, repeatedValue: 0)
print("===+++++++++====")
while true {
    read(client.socketFd, &buffer, buffer.count)
    //try Utils.readN(client.socketFd, buffer: &buffer , n: 5)
    print(buffer)
}
