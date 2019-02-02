
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
config = require 'config'
request = require 'request'
tempDir = require 'temp-dir'
uniqueFilename = require 'unique-filename'
unzip = require 'unzip'
zipIt = require 'zip-a-folder'
packer = require 'dir-packer'
JSZip = require 'jszip'
decompress = require 'decompress'
rimraf = require 'rimraf'
recursive = require "recursive-readdir"
fse = require 'fs-extra'

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
      #f = directory
      #a = toPath + path.sep + fileName
      #await zipIt.zip(f, a)
      template = await Template.fromDirectory(directory)
      buffer = await template.toArchive('javascript')
      saved = await saveBuffer(buffer, toPath + path.sep + fileName)
      #console.log 'before -------------------'
      #tempFileName = uniqueFilename(tempDir, 'tempzip')
      #console.log('will save bna file to ' + tempFileName)
      #saved = await saveBuffer(buffer, tempFileName)  
      # Extract zip to a temp folder
      #tempDirName = uniqueFilename(tempDir, 'tempzipdir')
      #console.log 'temp dir'
      #console.log tempDirName
      #fs.mkdirSync(tempDirName)
      #console.log tempFileName
      #tempDirName2 = tempDirName + '/'
      #await decompress(tempFileName, tempDirName2)
      # Modify folders contents
      #fse.copySync('./template/chaincode.js', tempDirName2 + 'chaincode.js')
      #fs.unlinkSync(tempDirName2 + 'lib/logic.js')
      #projectJsonFilePath = tempDirName2 + '/package.json'
      #projectJson = await fse.readJson(projectJsonFilePath)
      #projectName = projectJson.name
      #projectJson.name = projectName #+ '-' + projectId
      #projectJson.dependencies = {
      #  'fabric-shim': '^1.4.0'
      #};
      #projectJson.scripts = {
      #  start: 'node chaincode.js'
      #};
      #projectJson['engine-strict'] = true;
      #projectJson.engines = {
      #  node: '>=8.4.0',
      #  npm: '>=5.3.0'
      #};
      #projectJson.dependencies = {
      #  'fabric-shim': '~1.3.0'
      #};
      #projectJson.engineStrict = true;
      #fs.unlinkSync(projectJsonFilePath)
      #await fse.writeJson(projectJsonFilePath, projectJson, {spaces: 2})
      # Zip into a new zip file
      #zip = new JSZip
      #contents = await recursive(tempDirName2)
      #for d in contents
      #  f = fs.readFileSync(d, 'utf8')
      #  pathTrimmed = d.slice(tempDirName2.length)
      #  zip.file(pathTrimmed, f)
      #console.log ''
      #console.log contents
      #console.log ''
      #result = await zip.generateAsync(type: 'nodebuffer')
      ## Delete temp 
      #rimraf.sync(tempFileName)
      #rimraf.sync(tempDirName)
      #console.log 'after -------------------'
      #saved = await saveBuffer(result, toPath + path.sep + fileName)
      #
      #tempFileName = uniqueFilename(tempDir, 'tempzip')
      #bnaTempFileName = tempFileName
      #console.log('will save bna file to ' + bnaTempFileName)
      #saved = await saveBuffer(buffer, bnaTempFileName)
      # Extract to a temp directory
      #fs.mkdirSync(tempDir)
      #extractToDirectory = uniqueFilename(tempDir, 'tempdir')
      #fs.createReadStream(bnaTempFileName).pipe(unzip.Extract(path: extractToDirectory)).on 'close', ->
      #  console.log 'a'
      #  return
      #fs.createReadStream(bnaTempFileName).pipe unzip.Extract(path: extractToDirectory)
      # Change logic javascript file
      # Compress back into a archive and save to bnaFileName
      #bnaFileName = toPath + path.sep + fileName
      # @todo Save archive
      # @todo Delete temp files
      
      console.log saved
      nl
    catch error
      console.log error
      nl

  executeHyperledgerContract: (contractLogicalName, hyperledgerUuid, email, base64RequestJson, job) =>
    try
      console.log 'job is'
      console.log job
      console.log ''
      console.log 'execute hyperledger contract --------------------------------------------------------------------------'
      console.log 'contractLogicalName:' + contractLogicalName
      console.log 'hyperledgerUuid:' + hyperledgerUuid
      console.log 'email:' + email
      console.log 'base64RequestJson:' + base64RequestJson
      console.log ''
      bnaDeployUrl = config.get('server.executeHyperledgerContractUrl')
      body =
        'contractLogicalName': contractLogicalName,
        'hyperledgerUuid': hyperledgerUuid,
        'email': email,
        'base64RequestJson': base64RequestJson,
        'job': job
      console.log 'posting body'  
      console.log body
      request.post {
        url: bnaDeployUrl
        body: body
        json: true
      }, (error, response, body) ->
        console.log error
        if error
          return console.error('error:', error)
        console.log 'dontknow:', body
        return
    catch e 
      console.log e   

  deployBusinessNetworkArchiveToHyperledger: (fileName, hyperledgerUuid, email, job) =>
    console.log 'deployBusinessNetworkArchiveToHyperledger   '
    console.log fileName
    console.log hyperledgerUuid
    console.log 'job is'
    console.log job
    bnaDeployUrl = config.get('server.bnaDeployUrl')
    body =
      'job': job
      'uuid': hyperledgerUuid
      'bnaFileName': fileName
      'email': email
    console.log 'posting body'  
    console.log body
    request.post {
      url: bnaDeployUrl
      body: body
      json: true
    }, (error, response, body) ->
      console.log error
      if error
        return console.error('error:', error)
      console.log 'dontknow:', body
      return

  # composer network install -a car-sales-network.bna -c PeerAdmin@hlfv1
  deploy: (businessNetworkArchiveFile) =>
    console.log 'deploy to a hyperledger'
    'hi'

  # composer-rest-server -c admin@car-sales -n always -w true
  testRestServer: () =>
    console.log 'test rest server'
    'hi'

module.exports = HyperledgerDeploy
