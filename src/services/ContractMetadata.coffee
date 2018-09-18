
{ readdir: readdir, stat: stat } = require("fs").promises
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/ergo')
find = require 'find'

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
          console.log f
          result.push
            project_path: d
            cto_paths: f
    return result

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
