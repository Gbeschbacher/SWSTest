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
    Entry.collection.insert JSON.parse( message )
    ,
        w: 1
        keepGoing: true
    , (err) ->
        if err
            console.log "error while inserting"
        ++pageCount
        console.log pageCount
        if pageCount is 412
            console.timeEnd "overall"


