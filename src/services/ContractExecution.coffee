
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

class ContractExecution

  constructor: () -> 0

  test: () -> 0

  execute: (templatePath, samplePath, requestsPath, statePath) =>
    await Commands.execute templatePath, samplePath, requestsPath, statePath

module.exports = ContractExecution
