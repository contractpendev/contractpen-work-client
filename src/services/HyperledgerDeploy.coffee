
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
  createBusinessNetworkArchiveFile: (directory) =>
    directory = '/Users/philipandrew/projects/contractpen_template_dir/contract_d25ac229-eca0-4676-9ac2-29eca0c67675_neg396196837'
    fileName = 'test.bna'
    console.log 'create a business network archive file from accord project files'
    console.log directory
    nl = ''
    try
      template = await Template.fromDirectory(directory)
      buffer = await template.toArchive('ergo')
      saved = await saveBuffer(buffer, fileName)
      console.log saved
      n1
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
