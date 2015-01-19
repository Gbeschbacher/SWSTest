"use strict"

async = require "async"

WebSocketServer = require("ws").Server

config = require "./server_config"

entrySchema = require "./entrySchema"

{createConnection} = require "./db"
db = createConnection config

Entry = db.model "Entry", entrySchema

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
console.time "overall"

totalCbs = 0
myCb = ( err ) ->
    ++totalCbs
    if totalCbs >= 3
        console.timeEnd "overall"
        afterInit()

for type in config.types
    do (type) ->
        Entry.count ListType: type, (err, count) ->
            if err
                console.log "db error", err
                return myCb err
            else
                console.log "total #{type}: #{count}"
                diff = count - config.counts[type.toLowerCase()]
                console.log "diff #{type}", diff
                if diff is 0
                    return myCb err

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
                            return myCb err
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
                        return myCb err

afterInit = ->
    wss = new WebSocketServer port: config.wsPort

    wss.on "connection", connection = (ws) ->
        console.log "new connection"
        ws.on "message", incoming = (message) ->
            entries = 0
            entries += val for key,val of config.counts

            # 40k entries
            pageSize = 5000
            pages = 8

            if message is "get"
                async.timesSeries pages
                , (it, cb) ->
                    Entry.find().limit(pageSize).skip(it*pageSize).exec (err, entries) ->
                        ws.send JSON.stringify(entries)
                        cb()
                , (err) ->
                    if err


    # get 10 random number plates
    obus = []
    rndNumber = ->
        Math.floor(Math.random()*2060000)+1

    console.time "10 queries"
    async.times 100 , (it, cb) ->
        Entry.find().limit(1).skip(rndNumber()).exec (err, obu) ->
            if err
                console.log "error while getting obu"
            else
                obus.push obu[0].OBU
            cb()
    , (err) ->
        if err
            console.log "err while getting plates"
        else
            console.time "get obus"
            async.each obus, (obu, cbi) ->
                Entry.findOne "OBU": obu, (err, obu) ->
                    cbi( err )
            , (err) ->
                console.timeEnd "get obus"


# 1 --> create mongodb backup ~190MB
# 2 --> gzip it ~35MB
# 3 --> md5
# 4 --> send it over websockets