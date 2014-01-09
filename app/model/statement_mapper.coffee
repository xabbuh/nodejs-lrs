Validator = require '../validator/validator'
logger = require '../logger'
_ = require 'underscore'

# Provides operations for all statements on top
# of couchDB.
#
module.exports = class StatementMapper


  # Instanciates a new statement mapper.
  #
  # @param dbController
  #  the database-controller to be used by this mapper
  #
  constructor: (@dbController) ->
    @validator = new Validator 'app/validator/schemas/'

  # Returns all stored statements to the callback.
  #
  # TODO: one should be able to specify the maximum number of returned statements
  #
  getAll: (callback) ->
    @dbController.db.view 'find_by/id', (err, docs) =>
      if err
        logger.error "database access failed: " + err
        callback err, []
      else
        statements = []
        for doc in docs
          statements.push doc.value

        callback undefined, statements

  # Returns the statement with the given id to the callback.
  #
  # @param id
  #   id of the statement to look up
  #
  find: (id, callback) ->
    logger.info 'find statement: ' + id
    @dbController.db.view 'find_by/id', key: id, (err, docs) =>
      if err
        logger.error "database access failed: " + err
        callback err, []
      else
        switch docs.length
          when 0
            logger.info 'statement does not exist: ' + id
            # there is no statement with the given id
            # TODO callback ERROR, null
            callback undefined
          when 1
            logger.info 'statement found: ' + id
            # all right, one statement found
            callback undefined, docs[0].value
          else
            # should not happen, there are more
            # then one statements with the same id
            # TODO callback ERROR, null
            callback 'Multiple Statements for the same id found.'

  # Saves this statement to the database
  #
  save: (statement, callback) ->
    # Tries to store this statement and if there
    # is no id, it generates an id, otherwise
    # ist check the two statements for equality
    if statement?.id
      # If the id is already defined
      # validate Statement
      @validator.validateWithSchema statement, "xAPIStatement", (validatorErr) =>
        if validatorErr
          callback {code: 400, message: 'Statement is invalid.' }
        else
          # Check if the given id is already in the database
          @find statement.id, (err, foundStatement) =>
            if err
              logger.error 'find returned error: ' + err
              # There is no statement with the given id,
              # the given statement will be inserted
              callback err
            else
              if foundStatement
                if @_isEqual statement, foundStatement
                  # all right statement is already in the database
                  callback undefined, statement
                else
                  # conflict, there is a statement with the
                  # same id but a different content
                  callback {code: 409, message: 'Conflicting statement: Found a statement with the same id but a different content!' }
              else
                # statement does not exist yet, save it
                @dbController.db.save statement, (err, res) =>
                  callback err, statement
    else
      # No id is given, generate one
      statement.id = @generateUUID()
      logger.info 'generated statement id: ' + statement.id
      # validate the given statement with the generated id
      @validator.validateWithSchema statement, "xAPIStatement", (validatorErr) =>
        if validatorErr
          callback {code: 400, message: 'Statement is invalid.' }
        else
          @dbController.db.save statement, (err, res) =>
            callback err, statement

  # Checks whether two statements are equal
  # Currently by performing a deep comparison. TODO
  _isEqual: (s1, s2) ->
    _.isEqual(s1, s2)

  # Generates a UUID from the current date and a random number.
  # @see http://www.ietf.org/rfc/rfc4122.txt
  generateUUID: ->
    d = (new (Date)()).getTime()
    'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace /[xy]/g, (c) ->
      r = (d + Math.random()*16)%16 | 0
      d = Math.floor(d/16)
      d = if c is 'x' then r else (r & 0x3|0x8)
      d.toString(16)



