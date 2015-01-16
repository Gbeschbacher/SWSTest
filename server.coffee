"use strict"

async = require "async"

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
###
for type in config.types
    do (type) ->
        console.log "type", type
        Entry.count ListType: type, (err, count) ->
            if err
                console.log "db error", err
            else
                console.log "total #{type}: #{count}"
                diff = count - config.counts[type.toLowerCase()]
                return if diff is 0

                if diff > 0
                    # delete entrys
                    Entry.find().limit( diff ).remove (err) ->
                        if err
                            console.log "error while removing #{type} entries"
                        else
                            console.log "deleted: #{diff} #{type} entries"
                else
                    diff *= -1
                    console.log "add... #{diff} #{type}"

                    async.timesSeries diff
                    , (n, cb) ->
                        e = new Entry()
                        e.OBU = randomNumber()
                        e.Kennzeichen = randomString()
                        e.ListType = type

                        e.save (err) ->
                            cb err, e
                    , ( err, entries ) ->
                        if err
                            console.log "Error while adding #{entries.length} #{type} entries"
                        else
                            console.log "Successfully added #{entries.length} #{type} entries"