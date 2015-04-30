App = require "../app"
server = App.server
server.get "/artworks",(req,res,next)->
    offset = req.body.offset or 0
    count = req.body.count or 20
    console.log "artwork!!"
    App.Model.Artwork.find({})
    .limit(count)
    .skip(offset)
    .exec (err,results)->
        results ?= []
        res.success results.map (item)->
            item.toJSON {virtuals:true}

server.get "/artworks/:artworkId",(req,res,next)->
    try
        id = App.Model.Types.ObjectId.fromString req.params.artworkId
    catch e
        res.error new Errors.NotFound()
        return
    App.Model.Artwork.findOne {_id:id},(err,artwork)->
        if err
            res.error new Errors.ServerError "",{via:err}
            return
        res.success artwork.toJSON {virtuals:true}
