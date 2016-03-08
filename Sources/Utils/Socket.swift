//
//  Socket.swift
//  XcodeProject
//
//  Created by Tqtifnypmb on 3/2/16.
//  Copyright © 2016 Tqtifnypmb. All rights reserved.
//

import Foundation

internal final class Socket {
    
    var socketFd = Int32(-1)

    #if DEBUG
    class func createBoundTcpSocket(addr: String, port: UInt16, maxListenQueue: Int32 = SOMAXCONN) throws -> Socket {
        var addrToBind = sockaddr_in()
        addrToBind.sin_family = sa_family_t(AF_INET)
        addrToBind.sin_port = port.bigEndian
        addrToBind.sin_addr = in_addr(s_addr: inet_addr(addr))
        addrToBind.sin_len = UInt8(sizeof(sockaddr_in))
        addrToBind.sin_zero = (0, 0, 0, 0, 0, 0, 0, 0)
        
        let toBind = Socket.socketaddr_cast(&addrToBind)
        return try Socket.doCreateSocket(AF_INET, addrToBind: toBind, addrLen: socklen_t(sizeof(sockaddr_in)), maxListenQueue: maxListenQueue)
    }
    
    class func createBoundUnixSocket(path: String, maxListenQueue: Int32 = SOMAXCONN) throws -> Socket {
        var addrToBind = sockaddr_un()

        let pathLen = path.withCString { Int(strlen($0)) }
        guard pathLen < sizeofValue(addrToBind.sun_path) else {
            throw SocketError.UnableToBindSocket("Unix socket path too long")
        }
        
        withUnsafeMutablePointer(&addrToBind.sun_path.0) { pathPtr in
            path.withCString {
                strncpy(pathPtr, $0, pathLen)
            }
        }
        
        let addrLen = sizeof(sockaddr_un) - sizeofValue(addrToBind.sun_path) + pathLen
        addrToBind.sun_family = sa_family_t(AF_UNIX)
        addrToBind.sun_len = UInt8(addrLen)
        
        
        let toBind = Socket.socketaddr_cast(&addrToBind)
        return try Socket.doCreateSocket(AF_UNIX, addrToBind: toBind, addrLen: socklen_t(addrLen), maxListenQueue: maxListenQueue)
    }
    
    private class func socketaddr_cast(p: UnsafeMutablePointer<Void>) -> UnsafeMutablePointer<sockaddr> {
        return UnsafeMutablePointer<sockaddr>(p)
    }
    
    #endif
    
    func acceptConnection(remoteAddr: UnsafeMutablePointer<sockaddr> = nil, addrLen: UnsafeMutablePointer<socklen_t> = nil) throws -> Int32 {
        assert(self.socketFd != -1)
        let conn = accept(self.socketFd, remoteAddr, addrLen)
        guard conn != -1 else {
            throw SocketError.AcceptFailed(Socket.getErrorDescription())
        }
    
        return conn
    }
    
    // Poll on listened socket wait for connection
    // if timeout return false,  otherwise return true
    func waitForConnection() throws -> Bool {
        assert(self.socketFd != -1)
        
        var nfd = pollfd()
        nfd.fd = self.socketFd
        nfd.events = Int16(POLLIN)
        let ret = poll(&nfd, 1, -1)
        if ret == -1 {
            throw SocketError.SelectFailed(Socket.getErrorDescription())
        }
        return ret != 0
    }
    
    func closeSocket() {
        if self.socketFd != -1 {
            close(self.socketFd)
        }
    }
    
    class func getErrorDescription() -> String {
        return String.fromCString(strerror(errno)) ?? "Error \(errno)"
    }

    private class func doCreateSocket(domain: Int32, addrToBind: UnsafeMutablePointer<sockaddr>, addrLen: socklen_t, maxListenQueue: Int32) throws -> Socket {
        let socketFd = socket(domain, SOCK_STREAM, 0)
        guard socketFd != -1 else {
            throw SocketError.UnableToCreateSocket(Socket.getErrorDescription())
        }
        
        var enable = 1
        guard setsockopt(socketFd, SOL_SOCKET, SO_REUSEADDR, &enable, socklen_t(sizeofValue(enable))) != -1 else {
            throw SocketError.UnableToSetSocketOption(Socket.getErrorDescription())
        }
        
        guard bind(socketFd, addrToBind, addrLen) != -1 else {
            close(socketFd)
            throw SocketError.UnableToBindSocket(Socket.getErrorDescription())
        }
        
        guard listen(socketFd , maxListenQueue) != -1 else {
            close(socketFd)
            throw SocketError.UnableToListenSocket(Socket.getErrorDescription())
        }
        
        let sock = Socket()
        sock.socketFd = socketFd
        return sock
    }
}