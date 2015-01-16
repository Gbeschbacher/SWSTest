# SWSTest

    `npm install`

# Server
    `coffee server.coffee`

# Client
    `coffee client.coffee`

# simplest way to copy whole db:
    * on the server:
        `mongodump -d kompl -c entries -o - | bzip2 - > dump.bson.bz2`
    * on the server:
        serve file (nginx or similar)
    * on the client:
        `wget -O ./dump.bson.bz2 && mongorestore -d kompl ./dump.bson.bz2`