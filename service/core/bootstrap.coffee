async = require "async"
App = require "./app"
App.settings = require "./settings"
App.Errors = require "./errors"
mongoose = require "mongoose"
mongoose.connect "mongodb://localhost/pravo-example"
mongoose.connection.on "error",(err)=>
    console.error "fatal error mongodb",err
    process.exit(0)
mongoose.connection.once "open",()=>
    App.Model = require "./model"
    App.dbConnection = mongoose.connection
    App.isReady = true
    App.emit "ready"

App.warn = (args...)->
    console.log "WARN",args...
App.log = (args...)->
    console.log "LOG",args...
App.error = (args...)->
    console.log "ERROR",args...
App.fatal = (args...)->
    console.log "FATAL",args...
    App.emit "fatal"
