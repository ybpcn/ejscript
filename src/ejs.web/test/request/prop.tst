/*
    Test request properties inside a web server
 */
require ejs.web

const HTTP = App.config.uris.http

server = new HttpServer
server.listen(HTTP)
load("../utils.es")

server.on("readable", function (event, request: Request) {

    assert(absHome == (HTTP + "/"))
    assert(authGroup == null)
    assert(authType == null)
    assert(authUser == null)
    assert(autoFinalizing == true)
    assert(config && config.log && config.web)
    assert(contentLength == -1);
    assert(contentType == null)
    assert(cookies == null)
    assert(dir == ".")
    assert(encoding == null)
    assert(errorMessage == null)
    assert(extension == "html")
    assert(files == null)
    assert(filename == "index.html")
    assert(headers && header("Host") && header("Date") && header("Connection") && header("User-Agent"))
    assert(headers && header("host") && header("date") && header("coNNECTion") && header("user-AGENT"))
    assert(home == "../")
    assert(host == Uri(HTTP).host)
    assert(isSecure == false)
    assert(limits)
    assert(localAddress == "127.0.0.1")
    assert(log == App.log)
    assert(method == "GET")
    assert(originalMethod == "GET")
    assert(originalUri == (HTTP + "/index.html"))
    assert(params.toJSON() == "{}")
    assert(pathInfo == "/index.html")
    assert(port == 6700)
    assert(protocol == "HTTP/1.1")
    assert(query == null)
    assert(reference == null)
    assert(referrer == null)
    assert(remoteAddress == "127.0.0.1")
    assert(responseHeaders)
    assert(route == null)
    assert(scheme == "http")
    assert(scriptName == "")
    assert(server && server.documents == "." && server.home == ".")
    assert(sessionID == null)
    assert(status == 200)
    assert(uri == (HTTP + "/index.html"))
    finalize()
})

let http = new Http
http.get(HTTP + "/index.html")
http.wait()
http.close()
server.close()
