
Comedy = require 'comedy'
Awilix = require 'awilix'
Setup = require './Setup'

Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Engine = require('@accordproject/cicero-engine').Engine

start = ->
  setupServer = Setup.container.resolve 'SetupClient'
  setupServer.setup()

start()

