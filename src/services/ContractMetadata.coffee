
{ readdir: readdir, stat: stat } = require("fs").promises
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
#MetaData = require('@accordproject/cicero-core/lib/metadata')
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/ergo')
find = require 'find'
decycle = require('json-decycle').decycle

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

    template = await Template.fromDirectory('C:\\home\\projects\\contractpen_node_client\\testcicerofolder')
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

  metaDataOfProject: (projectDirectory) =>
    try
      console.log projectDirectory
      template = await Template.fromDirectory projectDirectory
      hash = template.getHash()
      identifier = template.getIdentifier()
      metadata = template.getMetadata()
      templateAst = template.getTemplateAst()
      # a string of the grammar
      grammar = template.getTemplatizedGrammar()
      # arrays of strings
      requestTypes = template.getRequestTypes()
      responseTypes = template.getResponseTypes()
      emitTypes = template.getEmitTypes()
      stateTypes = template.getStateTypes()

      result =
        hash: hash
        identifier: identifier
        metadata: metadata
        templateAst: templateAst
        grammar: grammar
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
