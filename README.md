# SWSTest

    `npm install`

# Server
    `coffee server.coffee`

# Client
    `coffee client.coffee`

# simplest way to copy whole db:
    * on the server:
        `mongodump -d kompl -c entries -o dump && tar -cjf dump.tar.bz2 dump/`
    * on the server:
        serve file (nginx or similar)
    * on the client:
        `wget -O ./dump.bson.bz2 URL && bzip -ckd ./dump.bson.bz2 && mongorestore -d kompl ./dump`