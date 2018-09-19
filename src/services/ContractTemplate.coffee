
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

  constructor: (opts) ->
    @nodeCache = opts.nodeCache

  test: () -> 0

  template: (inputJsonFile, directory) =>
    testLatePenaltyInput = JSON.parse(fs.readFileSync(inputJsonFile, 'utf8'))
    template = await Template.fromDirectory(directory)
    clause = new Clause(template)
    clause.setData testLatePenaltyInput
    n1 = clause.generateText()
    n1

module.exports = ContractTemplate
