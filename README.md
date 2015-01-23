# SWSTest

    `npm install`

# Requirements:
    * Node.js
    * MongoDB
    * CoffeeScript `npm install -g coffee-script`
    * Dependencies

# Config files:
    * `client_config.coffee`
    * `server_config.coffee`

# set up db:
    The `server.coffee` automaticaly sets up db, it will create
        * 2.000.000 white
        * 40.000 exempt
        * 20.000 exception
    entries (if there are more entries, it will remove the left over).


# simplest way to copy whole db:
    * on the server:
        `time mongodump -d kompl -c entries -o dump && tar -cjf dump.tar.bz2 dump/` --> takes about 17 secs, ~28MB Backup
    * on the server:
        serve file (nginx or similar)
    * on the client:
        `wget -O ./dump.bson.bz2 URL && time tar xvjf ./dump.tar.bz2 && mongorestore -d kompl_restore ./dump/kompl` --> takes about 1:10

# Swiss army knife:
(use replication)[http://docs.mongodb.org/manual/replication/]
