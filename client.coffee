WebSocket = require "ws"

config  =require "./client_config"

entrySchema = require "./entrySchema"

{createConnection} = require "./db"
db = createConnection config

Entry = db.model "Entry", entrySchema

ws = new WebSocket "ws://#{config.host}:#{config.port}"

ws.on "open", ->
    ws.send "get"

pageCount = 0
entries = 0
entries += val for key,val of config.counts
console.time "overall"
ws.on "message", ( message ) ->
    #console.log "got msg"
    msg = JSON.parse message
    i = 0
    while i < msg.length
        Entry.collection.update _id: msg[i]._id, msg[i]
        ,
            w: 1
            keepGoing: true
        , (err) ->
            if err
                console.log "error while inserting", err
            ++pageCount
            if pageCount >= 5000*8
                console.timeEnd "overall"
        ++i

