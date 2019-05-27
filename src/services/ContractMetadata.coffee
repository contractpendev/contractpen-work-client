
{ readdir: readdirSync, stat: statSync } = require("fs")
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
#MetaData = require('@accordproject/cicero-core/lib/metadata')
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/compiler')
find = require 'find'
decycle = require('json-decycle').decycle
file = require 'file-normalize'
uuidv4 = require 'uuid/v4'

class ContractMetadata

  constructor: () -> 0

  test: () -> 0

  ctoToJson: (inputFile) =>
    ctoText = fs.readFileSync(inputFile, 'utf8')
    Ergo.parseCTOtoJSON ctoText

  # @todo Remove method
  testClauseTemplate = ->
    testLatePenaltyInput = {
      "$class": "org.accordproject.helloworld.HelloWorldClause",
      "name": "Philip",
      "clauseId": "427c99b0-6df4-11e8-bb3b-67a2e79acc24"
    }

    dir = 'C:\\home\\projects\\contractpen_node_client\\testcicerofolder'

    template = await Template.fromDirectory(dir)
    clause = new Clause(template)
    clause.setData testLatePenaltyInput
    n1 = clause.generateText()
    console.log n1

  directoriesToJson: (directoryMetaData) =>
    console.log 'directoriesToJson:'
    console.log directoryMetaData
    result = []
    for d in directoryMetaData
      ctoPaths = d.cto_paths
      ctoPathsResult = []
      for c in ctoPaths
        console.log c
        json = @ctoToJson c
        ctoPathsResult.push
          ctoPath: c
          json: json
      result.push
        project_path: d.project_path
        cto_paths: ctoPathsResult
    return result

  # @todo Deduplicate method singleDirectory and iterateFoldersInDirectory
  singleDirectory: (directory) =>
    console.log 'singleDirectory in ContractMetadata as ' + directory
    dir = [directory]
    result = []
    dir.map (d) ->
      c = []
      files = find.fileSync d
      files.map (f) ->
        if f.toLowerCase().endsWith('.cto')
          c.push f

      #console.log f
      result.push
        project_path: d
        cto_paths: c

    return result

  # Finds all cto models
  # @todo Make more async
  iterateFoldersInDirectory: (directory) =>
    dir = await @directoriesIn directory
    result = []
    dir.map (d) ->
      c = []
      files = find.fileSync d
      files.map (f) ->
        if f.toLowerCase().endsWith('.cto')
          c.push f

      #console.log f
      result.push
        project_path: d
        cto_paths: c

    return result

  metaDataOfDirectoriesJson: (d) =>
    result = []
    for x in d
      console.log 'project path: ' + x.project_path
      meta = await @metaDataOfProject x.project_path
      console.log 'done'
      result.push
        project_path: x.project_path
        cto_paths: x.cto_paths
        meta_data: meta
    result

  executeTemplateWithTemplateClassInstance: (template, templatePath, samplePath, requestsPath, statePath) =>
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
    clause = new Clause(template)
    clause.parse sampleText
    clause.data

  metaDataOfProject: (projectDirectory) =>
    try
      console.log projectDirectory
      requestJson = ''
      try
        requestJson = fs.readFileSync(projectDirectory + path.sep + 'request.json', 'utf8')
      catch ex
        console.log ex
      template = await Template.fromDirectory projectDirectory
      samplePath = projectDirectory + path.sep + 'sample.txt'
      requestPath = [projectDirectory + path.sep + 'request.json']
      statePath = projectDirectory + path.sep + 'state.json'
      # Execute to extract the default data for the clause
      defaultClauseData = await @executeTemplateWithTemplateClassInstance(template, projectDirectory, samplePath, requestPath, statePath)
      hash = template.getHash()
      identifier = template.getIdentifier()
      metadata = template.getMetadata()
      templateAst = template.parserManager.getTemplateAst()
      # a string of the grammar
      #grammar = template.getTemplatizedGrammar()
      # arrays of strings
      requestTypes = template.getRequestTypes()
      responseTypes = template.getResponseTypes()
      emitTypes = template.getEmitTypes()
      stateTypes = template.getStateTypes()

      result =
        defaultClauseData: JSON.stringify(defaultClauseData)
        requestJson: requestJson
        hash: hash
        identifier: identifier
        metadata: metadata
        templateAst: templateAst
        grammar: null #grammar
        requestTypes: requestTypes
        responseTypes: responseTypes
        emitTypes: emitTypes
        stateTypes: stateTypes

      result
    catch ex
      console.log ex

  # ?
  directoriesIn: (directory) =>
    console.log 'directories in'
    filesAndDirectories = []
    d = await readdir directory
    for f in d
      dir = directory + path.sep + f
      s = await stat dir
      filesAndDirectories.push(dir) if s.isDirectory()
    return filesAndDirectories

  extractFromContract: () =>
    0

module.exports = ContractMetadata
