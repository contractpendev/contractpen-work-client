
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
file = require 'file-normalize'

class ContractExecution

  constructor: () -> 0

  test: () -> 0

  executeTemplate: (templatePath, samplePath, requestsPath, statePath) =>
    clause = undefined
    sampleText = fs.readFileSync(samplePath, 'utf8')
    sampleText = file.normalizeNL(sampleText)
    requestsJson = []
    stateJson = undefined
    i = 0
    while i < requestsPath.length
      requestsJson.push JSON.parse(fs.readFileSync(requestsPath[i], 'utf8'))
      i++
    if !fs.existsSync(statePath)
      console.log 'A state file was not provided, generating default state object. Try the --state flag or create a state.json in the root folder of your template.'
      stateJson =
        '$class': 'org.accordproject.cicero.contract.AccordContractState'
        stateId: uuidv4()
    else
      stateJson = JSON.parse(fs.readFileSync(statePath, 'utf8'))
    Template.fromDirectory(templatePath).then((template) ->
      clause = new Clause(template)
      clause.parse sampleText
      engine = new Engine
      # First execution to get the initial response
      firstRequest = requestsJson[0]
      initResponse = engine.execute(clause, firstRequest, stateJson)
      # Get all the other requests and chain execution through Promise.reduce()
      otherRequests = requestsJson.slice(1, requestsJson.length)
      otherRequests.reduce ((promise, requestJson) ->
        promise.then (result) ->
          engine.execute clause, requestJson, result.state
      ), initResponse
    ).catch (err) ->
      console.log err.message
      return

  execute: (templatePath, samplePath, requestsPath, statePath) =>
    try
      await @executeTemplate templatePath, samplePath, requestsPath, statePath
    catch e
      console.log e
      null

module.exports = ContractExecution
