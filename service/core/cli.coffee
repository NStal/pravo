require "mongoose"
commander = require "commander"

mongoose.connect "mongodb://localhost/pravo-example"
mongoose.connection.on "error",(err)=>
    console.error "fatal error mongodb",err
    process.exit(0)
mongoose.connection.once "open",()=>
    Model = require "./model"
    program = commander
    program
    .command "artwork <source> <fetch>"
    .option "--width","width of the artwork"
    .option "--height","height of the artwork"
    .action (source,id)=>
        width = parseInt program.width
        height = parseInt program.height
        if not width or not height
            console.error "invalid program"
        if source is "pixiv"
    .parse process.argv
