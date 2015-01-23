"use strict"

async = require "async"

WebSocketServer = require("ws").Server

config = require "./server_config"

entrySchema = require "./entrySchema"

{createConnection} = require "./db"
db = createConnection config

Entry = db.model "Entry", entrySchema

obus = []

getRandomOBUs = (cb) ->
    console.time "getRandomOBUs"

    rndNumber = ->
        Math.floor(Math.random()*2060000)+1
    async.times 100, (it, cbi) ->
        Entry.find().limit(1).skip(rndNumber()).exec (err, obu) ->
            if err
                console.log "error while getting obu"
            else
                obus.push obu[0].OBU
            cbi err
    , (err) ->
        if err
            console.log "err while getting obus"
        console.timeEnd "getRandomOBUs"
        cb err


findOBUs = (cb) ->
    console.log "find start"
    async.each obus, (obu, cbi) ->
        Entry.find {OBU: obu}, (err, obu) ->
            console.log "."
            if err
                console.log "error while looking up obu", obu
            cbi err, obu
    , ( err ) ->
        if err
            console.log "error while looking up obus"
        console.log "find end"
        cb err

getRandomOBUs ->
    console.time "find obus"
    findOBUs ->
        console.timeEnd "find obus"