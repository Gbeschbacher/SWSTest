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

inserts = []
for i in [1..5000]
    inserts.push
        OBU: randomNumber()
        Kennzeichen: randomString()
        ListType: "White"
        created: new Date()

async.eachSeries inserts
, (insert, cb) ->
    setTimeout ->
        Entry.collection.insert insert, (err) ->
            if err
                console.log "error while inserting ", err
            console.log "."
            cb err
    , 5
, (err) ->
    console.log "stop insert"

