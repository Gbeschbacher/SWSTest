"use strict"

async = require "async"
which = require "which"
fstream = require "fstream"
tar = require "tar"

zlib  = require "zlib"
fs    = require "fs"

WebSocketServer = require("ws").Server

config = require "./server_config"

entrySchema = require "./entrySchema"

{createConnection} = require "./db"
db = createConnection config

Entry = db.model "Entry", entrySchema

{spawn} = require "child_process"


randomNumber = ->
    Math.floor(Math.random()*1000000)+10000000

randomString = ->
    possible = "-ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    ( possible.charAt(
        Math.floor(
            Math.random() * possible.length)
        ) for i in [1..10]).join ""

###
on start, verify that following exists:
    2.000.000   Whitelist Entries
    40.000      Exempt Entries
    20.000      Exception Entries
takse ~ 70 sec
###
totalCbs = 0
cb = ( err ) ->
    ++totalCbs
    if totalCbs >= 3
        console.log "finished!"
        console.timeEnd "overall"
        afterInit()

console.time "overall"
for type in config.types
    do (type) ->
        console.log "type", type
        Entry.count ListType: type, (err, count) ->
            if err
                console.log "db error", err
                return cb err
            else
                console.log "total #{type}: #{count}"
                diff = count - config.counts[type.toLowerCase()]
                console.log "diff #{type}", diff
                if diff is 0
                    return cb err

                if diff > 0
                    # delete entrys
                    Entry.find().limit( diff ).select( "_id" ).exec ( err, entries ) ->
                        ids = entries.map (entry) -> entry._id

                        Entry.remove _id: {$in: ids}
                        , (err) ->
                            if err
                                console.log "error while removing #{type} entries"
                            else
                                console.log "deleted: #{diff} #{type} entries"
                            return cb err
                else
                    diff *= -1
                    console.log "add... #{diff} #{type}"

                    inserts = []
                    console.time(type)

                    for i in [1..diff]
                        inserts.push
                            OBU: randomNumber()
                            Kennzeichen: randomString()
                            ListType: type
                            created: new Date()

                    console.timeEnd(type)

                    # nativ insert is much faster (~10x)
                    Entry.collection.insert inserts
                    ,
                        w:1
                        keepGoing: true
                    , (err) ->
                        if err
                            console.log "error while inserting"
                        else
                            console.log "finished?"
                        return cb err

afterInit = ->
    console.log "finished!!!!"
    console.time "dump"
    args = ["--db", "kompl", "--collection", "entries"]
    mongodump = spawn which.sync("mongodump"), args
    mongodump.stdout.on "data", ( data ) ->
        console.log "stdout: " + data

    mongodump.stderr.on "data", ( data ) ->
        console.log "stderr: " + data

    mongodump.on "exit", ( code ) ->
        console.log "mongodump exited with code " + code
        console.timeEnd "dump"
        if code is 0

            console.time "gzip"
            ###
            input = fstream.Reader(
              path: "dump"
              type: "Directory"
            )
            out = fs.createWriteStream("dump.tar.gz")

            # Read the source directory
            # Convert the directory to a .tar file
            # Compress the .tar file
            input.pipe(tar.Pack()).pipe(zlib.Gzip()).pipe out
            input.on "end", ->
                console.log "gzip finished?"
                console.timeEnd "gzip"
            ###

            args = ["-zcvf", "dump.tar.gz", "./dump"]
            tar = spawn which.sync("tar"), args

            tar.stdout.on "data", ( data ) ->
                console.log "stdout: " + data

            tar.stderr.on "data", ( data ) ->
                console.log "stdout: " + data

            tar.on "exit", (code) ->
                console.log "tar finished with code: " + code
                console.timeEnd "gzip"



    wss = new WebSocketServer port: config.wsPort

    wss.on "connection", connection = (ws) ->
        console.log "new connection"
        ws.on "message", incoming = (message) ->
            entries = 0
            entries += val for key,val of config.counts

            pageSize = 5000
            pages = entries / pageSize

            if message is "get"
                console.log "get msg"
                async.timesSeries pages
                , (it, cb) ->
                    Entry.find().limit(pageSize).skip(it*pageSize).exec (err, entries) ->
                        ws.send JSON.stringify(entries)
                        cb()
                , (err) ->
                    if err
                        console.log "error ", err

# 1 --> create mongodb backup ~190MB
# 2 --> gzip it ~35MB
# 3 --> md5
# 4 --> send it over websockets


###
MyModel.find( { createdOn: { $lte: request.createdOnBefore } } )
.limit( 10 )
.sort( '-createdOn' )
        return

    ws.send "something"
    return
###