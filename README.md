##Introduction

Armature is a Swift FastCGI/CGI server inspired by Python WSGI [https://www.python.org/dev/peps/pep-3333/]. It's goal is :
- [x] To make writing FastCGI/CGI application as easy as writing a normal program.
- [x] Provide Python like interface
- [x] Highly adaptable

## Work in Progress

This is a work in progress, so *do not* rely on this for anything important.
All kind of Pull requests are welcome.

## Badges
[![PRs Welcome](https://img.shields.io/badge/prs-welcome-brightgreen.svg?style=flat-square)](http://makeapullrequest.com)

## Examples

Create a application
```
class MyApp : Application {
    func main(env: Environment, responder: Responder) -> Int32 {
        let respWriter = responder(status:"200", headers:["Content-Type": "text/html"])
        do {
            try writer("<!DOCTYPE html><html><head><meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\"></head><body>Hello world</body></html>" , nil)
        } catch {
        }
        return 0
    }
}
```

Run it
```
server.run(myApp)
```

## Compatibility

Currently Armature has not heavily tested yet. It's has been tested on OSX 10.11 , lighttpd.
