App = require "../app"
Errors = App.Errors
server = App.server
server.get "/devices",(req,res,next)->
    res.success req.user.devices or []
server.post "/devices",(req,res,next)->
    device = new App.Model.Device req.body
    req.user.devices ?= []
    req.user.devices.push device
    req.user.save (err)->
        if err
            res.error new Errors.ServerError "server error",err
            return
        res.success device.toJSON({virtuals:true})

server.param "deviceId",(req,res,next)->
    for device,index in req.user.devices
        if device.id is req.params.deviceId
            req.device = device
            req.deviceIndex = index
            next()
            return
    res.error new Errors.NotFound "device not found:#{req.params.deviceId}"
server.delete "/devices/:deviceId",(req,res,next)->
    req.user.devices.splice(req.deviceIndex,1)
    req.user.save (err)->
        if err
            res.error new Errors.ServerError "server error",err
            return
        res.success req.device.toJSON({virtuals:true})
        return
server.put "/devices/:deviceId/wallpaper",(req,res,next)->
    artwork = req.body.artwork
    width = req.body.width or req.device.width
    height = req.body.height or req.device.height
    top = req.body.top or 0
    left = req.body.left or 0
    if not artwork or not width or not height or not top? or not left?
        res.error new Errors.InvalidParameter "invalid parameter"
        return
    App.Model.Artwork.findOne {id:artwork},(err,art)->
        if err
            res.error new Errors.ServerError()
            return
        if not art
            res.error new Errors.NotFound "artwork id #{artwork} not found"
            return
        req.device.wallpaper = {
            width,height,left,top,artwork:art._id
        }
        req.user.save (err)->
            if err
                res.error new Errors.ServerError
                return
            res.success(req.device)
