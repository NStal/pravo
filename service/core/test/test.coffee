request = require "request"
jar = request.jar()
correctPassword = "12344321"
correctEmail = "lili.th@gmail.com"
mkurl = (path)->
    if path[0] is "/"
        path = path.substring(1)
    return "http://localhost:8080/#{path}"
resError = (res,data)->

resOK = (res,data,message)->
    data or throw new Error "invalid response #{data}"
    if typeof data is "string"
        try
            result = JSON.parse data
        catch e
            throw new Error "invalid response json #{data}"
    else
        result = data
    result.state is false and (message and message is result.error.name is message or not message)
    return result

resOK = (res,data)->
    res.statusCode is 200 and data or throw new Error "invalid response #{data}"
    if typeof data is "string"
        try
            result = JSON.parse data
        catch e
            throw new Error "invalid response json #{data}"
    else
        result = data

    result.state is true or throw new Error "invalid response state is false#{JSON.stringify result}",res
    return result
after (done)->
    console.log "destroy..."
    request.del {jar:jar,url:mkurl("/me")},(err,res,content)->
        resOK(res,content)
        done()

describe "test user related API",()->
    it "create user",(done)->
        request.post {jar:jar,url:mkurl("/me/register"),json:{email:correctEmail,password:correctPassword}},(err,res,content)->
            resOK(res,content)
            done()
    it "getuser",(done)->
        request.get {jar:jar,url:mkurl("/me")},(err,res,content)->
            resOK(res,content)
            done()
    it "sign out",(done)->
        request.del {jar:jar,url:mkurl("/me/session")},(err,res,content)->
            resOK(res,content)
            done()
    it "get user data not sign in should fail",(done)->
        request.get {jar:jar,url:mkurl("/me")},(err,res,content)->
            resError res,content,"AuthorizationFailed"
            done()
    it "sign in",(done)->
        request.post {jar:jar,url:mkurl("/me/session"),json:{email:correctEmail,password:correctPassword}},(err,res,content)->
            resOK(res,content)
            done()

describe "test devices",()->
    it "get devices",(done)->
        request.get {jar:jar,url:mkurl("/devices")},(err,res,content)->
            result = resOK(res,content)
            console.assert result.data instanceof Array
            console.assert result.data.length is 0
            done()
    ValidDeviceName = "My Device"
    ValidDeviceWidth = 600
    ValidDeviceHeight = 480
    ValidDeviceGuid = Math.random().toString()
    it "create device",(done)->
        request.post {jar:jar,url:mkurl("/devices"),json:{name:ValidDeviceName,width:ValidDeviceWidth,height:ValidDeviceHeight,deviceGuid:ValidDeviceGuid,varient:null,wallpaper:null}},(err,res,content)->
            result = resOK(res,content)
            console.assert result.data.name is ValidDeviceName
            done()
    TestDevice = null
    it "get devices",(done)->
        request.get {jar:jar,url:mkurl("/devices")},(err,res,content)->
            result = resOK(res,content)
            console.assert result.data instanceof Array
            console.assert result.data.length is 1
            device = result.data[0]
            console.assert device.name is ValidDeviceName
            console.assert device.width is ValidDeviceWidth
            console.assert device.height is ValidDeviceHeight
            console.assert device.deviceGuid is ValidDeviceGuid
            TestDevice = device

            done()
    it "delete device",(done)->
        request.get {jar:jar,url:mkurl("/devices")},(err,res,content)->
            result = resOK res,content
            device = result.data[0]
            request.del {jar:jar,url:mkurl("/devices/#{device._id}")},(err,res,content)->
                result = resOK res,content
                request.get {jar:jar,url:mkurl("/devices")},(err,res,content)->
                    result = resOK res,content
                    console.assert result.data.length is 0
                    done()
