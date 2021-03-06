/*
    Stream I/O using Controller.write
 */
require ejs.web

const HTTP = App.config.uris.http

public class TestController extends Controller {
    use namespace action

    action function big() {
        dontAutoFinalize()
        let count = 0
        on("writable", function (event) {
            if (count++ < 1000) {
                write("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: " + count + "\n")
            } else {
                finalize()
            }
        })
    }
} 

load("../utils.es")
server = controllerServer(HTTP)


//  Async fetch with async writing

let http = new Http
http.afetch("GET", HTTP + "/test/big")
App.waitForEvent(http, "close", 30000)
assert(http.status == 200)
assert(http.response.length > 0)
assert(http.response.contains("aa: 1000"))
http.close()

server.close()
