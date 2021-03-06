request = require "supertest"
fs = require "fs"

##
# start server
##
server = require "setup_server.coffee"
exampleStatements = require "example_statements.coffee"

invalidStatements = "test/data/1.0.0/invalid/statement/"

request = request server

fs.readdir invalidStatements, (err, files) ->
  for file in files
    describe "POST an invalid statement", ->
      describe "from file: #{file}", ->
        it "responds with 400 Bad Request", (done) ->
          fs.readFile invalidStatements + file, (err, data) ->
            if err
              console.log "error reading file '#{file}'. #{err}"
              done(err)
              return
            request
              .post("/statements")
              .send(data)
              .expect(400, done)
