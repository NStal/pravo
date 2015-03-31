App = require "../app"
Errors = App.Errors
server = App.server

server.post "/me/register",(req,res,next)->
    email = req.body.email or null
    password = req.body.password or null
    if not email
        res.error new Errors.InvalidParameter "register require email"
        return
    App.Model.User.findOne  {email:email},(err,user)->
        if user
            res.error new Errors.AlreadyExists "user email already exists"
            return
        newby = new App.Model.User {email,devices:[]}
        try
            newby.setPassword password
        catch e
            res.error e
            return
        newby.save (err,result)->
            if err
                if err.name is "ValidationError"
                    res.error new Errors.InvalidParameter "fail to save user",{via:err}
                else
                    res.error new Errors.UnknownError "fail to save user",{via:err}
                return
            req.session.userId = result.id
            res.success result.getClientJson()
            return
server.post "/me/session",(req,res,next)->
    email = req.body.email
    password = req.body.password or ""
    if not email or not password
        res.error new Errors.InvalidParameter "invalid email or password"
        return
    App.Model.User.findOne {password:App.Model.User.computePasswordHash(password),email:email},(err,user)->
        if err
            res.error new Errors.ServerError "server error",{via:err}
            return
        req.session.userId = user.id
        res.success user.getClientJson()

server.all "*",(req,res,next)->
    if not req.session.userId or typeof req.session.userId isnt "string"
        next()
        return
    try
        console.log "try cast",req.session.userId
        id = App.Model.Types.ObjectId.createFromHexString req.session.userId
    catch e
        App.warn "invalid user id",req.session.userId,e
        next()
        return
    App.Model.User.findOne {_id:id},(err,user)->
        if err
            App.error err
        req.user = user or null
        console.log "set user",user.toJSON()
        next()
# All router after this requires login
server.all "*",(req,res,next)->
    if not req.user
        res.error new Errors.AuthorizationFailed()
        return
    next()
server.get "/me",(req,res,next)->
    if req.user
        res.success req.user.getClientJson()
        return
    req.error new Errors.AuthorizationFailed()
server.delete "/me",(req,res,next)->
    req.user.remove ()->
        res.success()
server.delete "/me/session",(req,res,next)->
    req.session.destroy ()->
        res.success()
server.post "/me/password",()->
    if not req.user
        res.error new Errors.AuthorizationFailed()
        return
    email = req.user.email
    oldPassword = req.body.oldPassword or ""
    newPassword = req.body.newPassword or ""
    if not oldPassword or not newPassword
        res.error new Errors.InvalidParameter "invalid password"
        return
    App.Model.User.findOne {email,password:App.Model.User.computePasswordHash(oldPassword)},(err,user)->
        if err
            res.error new Errors.ServerError "server error",{via:err}
            return
        try
            user.setPassword newPassword
        catch e
            res.error e
            return
        user.save (err,result)->
            if err
                if err.name is "ValidationError"
                    res.error new Errors.InvalidParameter "fail to change password",{via:err}
                else
                    res.error new Errors.UnknownError "fail to change password"      ,{via:err}
                return
            else
                res.success result.getClientJson()
