"use strict"

class Config
    constructor: ->
        @host   = "localhost"
        @port   = 3000
        @dbName = "kompl"
        @dbHost = @host
        @mongo  = "#{ @dbHost }/#{ @dbName }"
        @types  = ["White", "Exempt", "Exception"]
        @counts =
            exempt:     40000
            white:      2000000
            exception:  20000

module.exports = new Config