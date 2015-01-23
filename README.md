# SWSTest



## Requirements:
* Node.js
* MongoDB
* CoffeeScript `npm install -g coffee-script`
* Dependencies `npm install`

## Config files:
* `client_config.coffee`
* `server_config.coffee`

## set up db:
The `server.coffee` automaticaly sets up db, it will create

* 2.000.000 white
* 40.000 exempt
* 20.000 exception

entries (if there are more entries, it will remove the left over).


## simplest way to copy whole db:
* on the server:
    `time mongodump -d kompl -c entries -o dump && tar -cjf dump.tar.bz2 dump/` --> takes about 18 secs, ~28MB Backup
* on the server:
    serve file (nginx or similar)
* on the client:
    `wget -O ./dump.bson.bz2 URL && time tar xvjf ./dump.tar.bz2 && time mongorestore -d kompl_restore ./dump/kompl ` --> takes about 70 seconds

## insert 40k entries
* `coffee obu_insert_40k.coffee`
* --> takes about 2.3 seconds

## find while inserting entries
* `coffee obu_find.coffee`  --> select 100 random entries
* `coffee obu_insert.coffee` --> make an insert every 1ms (1k entries / sec)
* --> takes about 50ms

## copy 40k entries from server to client (using websockets)
* `coffee server.coffee`, wait till `WebSocketServer started` appears.
* `coffee client.coffee`
*  40k entries will take about 5.5 seconds (cause on the client side, it makes an update, not an insert)

## Swiss army knife:
use [replication](http://docs.mongodb.org/manual/replication/)
