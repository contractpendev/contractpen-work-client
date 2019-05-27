
{ readdir: readdirSync, stat: statSync } = require("fs")
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Commands = require('@accordproject/cicero-cli/lib/commands')
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/compiler')
find = require 'find'

class ContractTemplate

  constructor: (opts) ->
    @nodeCache = opts.nodeCache

  test: () -> 0

  template: (jsonData, grammar, directory) =>
    console.log 'template called with directory'
    console.log directory
    console.log 'grammar is'
    console.log grammar
    console.log 'json data'
    console.log jsonData
    
    nl = ''
    try
      template = await Template.fromDirectory(directory)
      template.buildGrammar(grammar) if grammar
      clause = new Clause(template)
      clause.setData jsonData
      n1 = clause.generateText()
      console.log n1
      n1
    catch error
      console.log error
      nl

module.exports = ContractTemplate
