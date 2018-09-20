
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

  template: (jsonData, grammar, directory) =>
    template = await Template.fromDirectory(directory)
    template.buildGrammar(grammar) if grammar
    clause = new Clause(template)
    clause.setData jsonData
    n1 = clause.generateText()
    console.log n1
    n1

module.exports = ContractTemplate
