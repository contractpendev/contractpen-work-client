
{ readdir: readdir, stat: stat } = require("fs").promises
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Commands = require('@accordproject/cicero-cli/lib/commands')
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/ergo')
find = require 'find'

class ContractTemplate

  constructor: () -> 0

  test: () -> 0

  template: (inputJsonFile, directory) =>
    # @todo Read input json file
    testLatePenaltyInput = {
      "$class": "org.accordproject.helloworld.HelloWorldClause",
      "name": "Philip",
      "clauseId": "427c99b0-6df4-11e8-bb3b-67a2e79acc24"
    }

    template = await Template.fromDirectory(directory)
    clause = new Clause(template)
    clause.setData testLatePenaltyInput
    n1 = clause.generateText()
    console.log n1
    n1

module.exports = ContractTemplate
