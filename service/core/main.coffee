bootstrap = require "./bootstrap"
App = require "./app"
App.on "ready",()->
    require "./server"
