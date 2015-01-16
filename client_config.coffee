"use strict"

class Config
    constructor: ->
        @host   = "localhost"
        @port = 8765
        @dbName = "kompl_client"
        @dbHost = @host
        @mongo  = "#{ @dbHost }/#{ @dbName }"
        @types  = ["White", "Exempt", "Exception"]
        @counts =
            exempt:     40000
            white:      2000000
            exception:  20000

module.exports = new Config