##Introduction

Armature is a Swift FastCGI/CGI server inspired by Python [WSGI](https://www.python.org/dev/peps/pep-3333/). It's goal is :
- [x] To make writing FastCGI/CGI application as easy as writing a normal program.
- [x] Provide Python like interface
- [x] Highly adaptable

## Work in Progress

This is a work in progress, so *do not* rely on this for anything important.
All kind of Pull requests are welcome.

## Badges
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Tutorial

How to create a application

- First of all, you create a application by:
```
    class MyApp: Application
```

- Second of all, you implement the main function of you application.
```
    func main(env: Environment, responder: Responder) -> Int32 {
        // You do something here

        // Finally, you return the status of you application to the server
    }
```

- Third of all

    You create a CGIServer
```
    let server = CGIServer()
```

    Or, you create a FCGIServer
```
    let server = FCGIServer()
    
    //or, if you want to support multi-connections handling

    let server = FCGIServer(threaded: true)
```
    *NOTE that if set your server threaded, you have make sure that your application is ok with multithread*

- Finally

    Run it
```
    let app = MyApp()

    // You can change server's connection type, before you run it
    // If you want to support request multipex you can
    server.connectionType = MultiplexConnection.self

    server.run(app)
```

## Example
```
class MyApp : Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let writer = responder(status: "200", headers: ["Content-Type": "text/html"])
            do {
                    try writer(output: "<!DOCTYPE html><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">from armature fastcgi</head><body>", error: nil)
                    try writer(output: env.request.params.description, error: nil)
                    try writer(output: form , error: nil)


                    if env.CONTENT_LENGTH > 0 {
                        try writer(output: "===>" + String(env.CONTENT_LENGTH), error: nil)

                            var input = [UInt8].init(count: Int(env.CONTENT_LENGTH), repeatedValue: 0)
                            try env.STDIN.readInto(&input)
                            if let cnt = String(bytes: input, encoding: NSUTF8StringEncoding) {
                                try writer(output: cnt, error: nil)
                            }
                    }

                try writer(output: "</error: body></html>", error: nil)

            } catch {
                assert(false)
            }
        return 0
}

let app = MyApp()
let server = FCGIServer()
server.run(app)
```

## Assumpsions

As a programmer who wants to write a CGI/FastCGI application, I assume you know about how CGI/FastCGI works. So Armature's goal is to provider enough features but not too much, We want to make it easy and clean.

## Compatibility

Currently Armature has not heavily tested yet. It's has been tested on OSX 10.11 , lighttpd.

## Attributions

This project is base on [flup](https://pypi.python.org/pypi/flup) and [web.py](http://webpy.org). Go checkout and star their repos.

## TODO

- More tests
- Port to Linux
