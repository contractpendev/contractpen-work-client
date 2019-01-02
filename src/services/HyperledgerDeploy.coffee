
{ readdir: readdirSync, stat: statSync } = require("fs")
{ join: join } = require("path")
fs = require 'fs'
path = require 'path'
Template = require('@accordproject/cicero-core').Template
Clause = require('@accordproject/cicero-core').Clause
Commands = require('@accordproject/cicero-cli/lib/commands')
Engine = require('@accordproject/cicero-engine').Engine
Ergo = require('@accordproject/ergo-compiler/lib/ergo')
find = require 'find'
saveBuffer = require 'save-buffer'

class HyperledgerDeploy

  constructor: (opts) ->
    @nodeCache = opts.nodeCache

  test: () -> 0

  # composer archive create -t dir -n . -a sample-network@0.0.1.bna
  # fromPath is the path to the nodejs project
  # toPath is the path to where we wish to save the bna file
  # fileName is the name of the file to save
  createBusinessNetworkArchiveFile: (fromPath, toPath, fileName) =>
    # C:\home\projects\accordtest
    directory = fromPath #'/home/projects/accordtest'
    console.log 'create a business network archive file from accord project files'
    console.log directory
    console.log toPath + path.sep + fileName
    nl = ''
    try
      template = await Template.fromDirectory(directory)
      buffer = await template.toArchive('javascript')
      saved = await saveBuffer(buffer, toPath + path.sep + fileName)
      console.log saved
      nl
    catch error
      console.log error
      nl

  # composer network install -a car-sales-network.bna -c PeerAdmin@hlfv1
  deploy: (businessNetworkArchiveFile) =>
    console.log 'deploy to a hyperledger'
    'hi'

  # composer-rest-server -c admin@car-sales -n always -w true
  testRestServer: () =>
    console.log 'test rest server'
    'hi'

module.exports = HyperledgerDeploy
