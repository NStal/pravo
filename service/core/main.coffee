require "./bootstrap"
App = require "./app"
express = require "express"
session = require "express-session"
bodyParser = require "body-parser"
MongoStore = (require "connect-mongo")(session)

server = express()
App.server = server

server.use session {
    secret:App.settings.sessionSecret
    store:new MongoStore {
        mongooseConnection:App.dbConnection
        ttl:App.settings.sessionExpires
        saveUninitialized:false
    }
}
server.use bodyParser {}
server.all "*",(req,res,next)->
    console.debug req.session
    if not server.isReady
        res.end "connecting db"
        return
    next()
require("./api/base")
require("./api/artwork")
require("./api/user")
require("./api/device")
server.listen 8080
