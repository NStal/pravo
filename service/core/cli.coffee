mongoose = require "mongoose"
commander = require "commander"
request = require "request"
pathModule = require "path"
urlModule = require "url"
http = require "http"
cheerio = require "cheerio"
settings = require "./settings"
sizeOfImage = require "image-size"
crypto = require "crypto"
Model = null
fs = require "fs"
panic = (args...)->
    console.error args...
    process.exit(1)
mongoose.connect "mongodb://localhost/pravo-example"
mongoose.connection.on "error",(err)=>
    console.error "fatal error mongodb",err
    process.exit(0)
mongoose.connection.once "open",()=>
    Model = require "./model"
    program = commander
    .option "--width <width>","width of the artwork"
    .option "--height <height>","height of the artwork"
    .option "--type <type>","typeof the artwork"
    .parse process.argv
    if program.type not in ["pixiv"]
        panic "invalid artwork type #{program.type}"
    uri = program.args[0]
    if not uri
        panic "request a artwork uri"
    Crawler[program.type] uri,{},(err,result)->
        if err
            panic err
            return
        addArtwork {type:program.type,id:result.id,filePath:result.path},(err,result)->
            if err
                panic err
                return
            console.log "add artworks",result
            process.exit(0)
Accounts = require "./accounts.coffee"
Crawler = {
    pixiv:(url,option = {},callback = ()->)->
        object = urlModule.parse url,true
        illustId = object.query.illust_id
        if not illustId
            callback new Error "missing illust id for url #{url}"
            return
        loginUrl = "http://www.pixiv.net/login.php"
        params = {
            mode:"login"
            return_to:"/mypage.php"
            pixiv_id:Accounts.pixiv.username
            pass:Accounts.pixiv.password
            skip:1
        }
        jar = request.jar()
        option = urlModule.parse loginUrl
        request.post {url:loginUrl,jar:jar,form:params,headers:{
                "Referer":"http://www.pixiv.net/"
                "Origin":"http://www.pixiv.net"
                "User-Agent":@UA
                "Accept":"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
        }},(err,res,result)->
            if err
                callback err
                return

            if res.headers.location and res.headers.location.indexOf('login') > 0
                callback new Error "fail to login likely to be invalid username and password"
                return
            illustUrl = "http://www.pixiv.net/member_illust.php?mode=medium&illust_id=#{illustId}"
            console.log "loginned"
            request.get {jar:jar,url:illustUrl},(err,res,content)->
                if err
                    callback err
                    return
                $ = cheerio.load content.toString()
                target = $(".original-image")[0]
                if not target
                    callback new Error "fail to find the original image"
                    return
                src = $(target).attr "data-src"
                request.get {url:src,encoding:null,headers:{referer:illustUrl},jar:jar},(err,res,content)->
                    if err
                        callback err
                        return
                    if res.statusCode isnt 200
                        callback new Error "fail to download image status code #{res.statusCode}"
                        return
                    console.log "download buffer length",content.length,Buffer.isBuffer content
                    path = "./temp/"+Math.random().toString().substring(3)
                    extname = pathModule.extname src
                    resultPath = path + extname
                    fs.writeFileSync resultPath,content
                    callback null,{path:resultPath,id:illustId,fetch:{illustId:illustId,maybeSrc:src}}
}
addArtwork = (info,callback = ()->)->
    try
        dimension = sizeOfImage info.filePath
    catch e
        callback e
        return
    if not dimension
        console.error "broken image file"
        callback new Error "fail to get image dimension likely to be a broken image"
        return
    hex = crypto.createHash("md5").update(info.type + info.id).digest("hex")
    storePath = pathModule.join settings.artworkStore,hex + pathModule.extname info.filePath
    fs.renameSync info.filePath,storePath
    console.log "add artwork to store",storePath
    artwork = new Model.Artwork {
        width:dimension.width
        height:dimension.height
        uid:hex
        origin:info.type
        fetch:info.fetch
        format:dimension.type or "jpg"
    }
    artwork.save (err)=>
        if err
            console.error "fail to save artwork due to err #{err}"
            callback err
            return
        console.log "create artwork",artwork
        callback(null,artwork)

    return
