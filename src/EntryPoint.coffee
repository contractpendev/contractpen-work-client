
Comedy = require 'comedy'
Awilix = require 'awilix'
Setup = require './Setup'

Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Engine = require('@accordproject/cicero-engine').Engine

start = ->
  setupServer = Setup.container.resolve 'SetupClient'
  setupServer.setup()

testClauseTemplate = ->
  console.log(Setup.container)
  setupGraph = Setup.container.resolve 'SetupGraph'
  setupGraph.setup()

  testLatePenaltyInput = {
    "$class": "org.accordproject.latedeliveryandpenalty.LateDeliveryAndPenaltyClause",
    "forceMajeure": true,
    "penaltyDuration": {
        "$class": "org.accordproject.time.Duration",
        "amount": 537704789,
        "unit": "hours"
    },
    "penaltyPercentage": 160.789,
    "capPercentage": 63.475,
    "termination": {
        "$class": "org.accordproject.time.Duration",
        "amount": 4149649232,
        "unit": "minutes"
    },
    "fractionalPart": "seconds",
    "clauseId": "427c99b0-6df4-11e8-bb3b-67a2e79acc24"
  }

  template = await Template.fromDirectory('C:\\home\\projects\\ContractPen\\cicero-template-library\\src\\latedeliveryandpenalty')
  clause = new Clause(template)
  clause.setData testLatePenaltyInput
  n1 = clause.generateText()
  console.log n1





#myActor = Setup.container.resolve('MyActor')
#myActor.sayHello('phil')
#myactor.sayHello('philip')
#gun.get('mark').on (data, key) ->
#  console.log 'update:', data
#rootActor = await actorSystem.rootActor()
#myActor = await rootActor.createChild MyActor
#myActor.send 'sayHello', 'world'

start()

