mongoose = require "mongoose"

module.exports.db = undefined

module.exports.createConnection = ( config ) ->
        connect = ->
            module.exports.db = mongoose.createConnection config.mongo,
                server:
                    socketOptions:
                        keepAlive: 1

            module.exports.db.on "error", (error) ->
                console.log "error while creating db connection"
                console.log error

            module.exports.db.on "disconnected", ->
                console.log "disconnected from server, trying to reconnect"
                connect()

            module.exports.db.once "open", ->
                console.log "db connection opened"

            module.exports.db

        connect()