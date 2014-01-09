fs = require "fs"

exampleStatements = require "example_statements.coffee"

describe "POST", ->
  # FIXME: You dont know which of these tests is finished first.
  #        Does it matter?
  #        Only in terms of provided descriptions.

  request = null
  beforeEach (done) ->
    require('setup_server').prepareTest (err, req) ->
      request = req
      done err

  describe "a minimal valid statement that doesn't exist yet", ->
    it "responds with 200 OK", (done) ->
      fs.readFile 'utf-8', exampleStatements.minimalWithoutId, (err, data) ->
        request
          .post("/statements")
          .set('Content-Type', 'application/json')
          .send(data)
          .expect(200, done)

  # FIXME: this assumes the item DOES exist
  describe "a minimal valid statement that exists already", ->
    it "SHOULD respond with 200 OK", (done) ->
      fs.readFile 'utf-8', exampleStatements.minimalWithoutId, (err, data) ->
        request
          .post("/statements")
          .set('Content-Type', 'application/json')
          .send(data)
          .expect(200, done)
  #
  # FIXME: we can't rely on the first statement being saved before the second request
  # ("The LRS MAY respond before Statements that have been stored are available for retrieval.",
  # xAPI 1.0.0 spec)
  describe "a minimal valid statement with an ID that exists already", ->
    it "SHOULD respond with 409 Conflict", (done) ->
      fs.readFile 'utf-8', exampleStatements.minimalWithId, (err, data) ->
        request
          .post("/statements")
          .set('Content-Type', 'application/json')
          .send(data)
          .end()
        request
          .post("/statements")
          .set('Content-Type', 'application/json')
          .send(data.toString())
          .expect(409, done)
