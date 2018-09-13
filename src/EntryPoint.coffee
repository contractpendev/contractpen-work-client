
Comedy = require 'comedy'
Awilix = require 'awilix'
Setup = require './Setup'

Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Engine = require('@accordproject/cicero-engine').Engine

start = ->
  testClauseTemplate()
  #setupServer = Setup.container.resolve 'SetupClient'
  #setupServer.setup()

# This function is NOT in use, just here for demonstration purpose
testClauseTemplate = ->
  testLatePenaltyInput = {
    "$class": "org.accordproject.helloworld.HelloWorldClause",
    "name": "Philip",
    "clauseId": "427c99b0-6df4-11e8-bb3b-67a2e79acc24"
  }

  template = await Template.fromDirectory('C:\\home\\projects\\contractpen_node_client\\testcicerofolder')
  clause = new Clause(template)
  clause.setData testLatePenaltyInput
  n1 = clause.generateText()
  console.log n1

start()

