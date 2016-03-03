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
        var addr = sockaddr_in()
        addr.sin_family = sa_family_t(AF_INET)
        addr.sin_port = port.bigEndian
        addr.sin_addr = in_addr(s_addr: inet_addr(ip))
        addr.sin_len = UInt8(sizeof(sockaddr_in))
        addr.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        let toConnect = self.socketaddr_cast(&addr)
        self.socketFd = socket(Int32(AF_INET), SOCK_STREAM, 0)
        connect(socketFd, toConnect, socklen_t(sizeof(sockaddr_in)))
    }
    
    func socketaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(p)
    }
}

let get_value_record = Record()
get_value_record.type = RecordType.GET_VALUE
get_value_record.requestId = 0
let request = ["FCGI_MAX_REQS": ""]
let bytes = Utils.encodeNameValueData(request)
print(bytes)
get_value_record.contentLength = UInt16(bytes.count)
get_value_record.contentData = bytes

let client = SimpleClient()
client.connectTo("127.0.0.1", port: 9999)
try get_value_record.writeTo(client.socketFd)

var buffer = [UInt8].init(count: 10, repeatedValue: 0)
while true {
    read(client.socketFd, &buffer, buffer.count)
    //try Utils.readN(client.socketFd, buffer: &buffer , n: 5)
    print(buffer)
}
