config = require './config.coffee'
passport = require 'passport'

# Passport middleware configuration on a per route basis
#

module.exports =
  '\/agent': [ passport.authenticate 'token', { session: false } ] if config.server.oauth
  '\/statements': [ passport.authenticate 'token', { session: false } ] if config.server.oauth
  '/about': []
  '/': []
