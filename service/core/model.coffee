mongoose = require "mongoose"
Schema = mongoose.Schema
crypto = require "crypto"
App = require "./app"
Errors = App.Errors
validator = require "validator"
ArtworkSchema = new Schema {
    width:Number
    height:Number
    fetch:{}
    origin:String
}
DeviceSchema = new Schema {
    name:String
    width:
        type:Number
        required:true
        min:0
    height:Number
        type:Number
        required:true
        min:0
    deviceGuid:String
    variant:String
    wallpaper:{
        width:Number
        height:Number
        left:Number
        top:Number
        resource:{ref:"Artwork",type:Schema.Types.ObjectId}
    }
}

UserSchema = new Schema {
    name:String
    email:String
    password:String
    devices:[DeviceSchema]
}
UserSchema.path("email").validate validator.isEmail
UserSchema.methods.getClientJson = ()->
    result = @toJSON()
    delete result.password
    return result

UserSchema.statics.computePasswordHash = (password)->
    hash1 = crypto.createHash("md5").update(password+App.settings.passwordSalt).digest("hex")
    hash2 = crypto.createHash("sha1").update(hash1+App.settings.passwordSalt).digest("hex")
    return hash2
UserSchema.methods.setPassword = (password = "")->
    minPasswordLength = 6
    if password.length < minPasswordLength
        throw new Errors.InvalidParameter "password should be at least #{minPasswordLength} chars"

    this.password = UserSchema.statics.computePasswordHash password
    return true
exports.User = mongoose.model "User",UserSchema
exports.Device = mongoose.model "Device",DeviceSchema
exports.Artwork = mongoose.model "Artwork",ArtworkSchema
exports.Types = mongoose.Types
exports.User.schema
exports.User.schema.path
