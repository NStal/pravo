App = require "../app"
server = App.server
server.use (req,res,next)->
    res.json = (json)->
        res.setHeader "content-type","text/json"
        res.end JSON.stringify json
    res.error = (err,code)->
        if code
            res.statusCode = code
        res.json {
            state:false
            error:err
        }
    req.success = (data,code)->
        res.json {
            state:true
            data:data
        }
    next()
