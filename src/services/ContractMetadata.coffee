
{ readdir: readdir, stat: stat } = require("fs").promises
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'

class ContractMetadata

  constructor: () -> 0

  test: () -> 0

  # ?
  iterateFoldersInDirectory: (directory) =>
    dir = await @directoriesIn directory
    result = []
    dir.map (d) ->
      result.push
        project_path: d
        cto_paths: ['nothing', 'in', 'here']
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
