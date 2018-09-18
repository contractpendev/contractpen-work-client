
Entities = require('html-entities').AllHtmlEntities
Handlebars = require 'handlebars'
helpers = require('handlebars-helpers')(handlebars: Handlebars)
express = require 'express'
bodyParser = require 'body-parser'
fs = require 'fs'
graphQlRequest = require 'graphql-request'
program = require 'commander'
path = require 'path'
ClusterWS = require './../../node_modules/clusterws-client-js/dist/index.js'
request = require 'request'
uuidv1 = require 'uuid/v1'
ContractMetadata = require './ContractMetadata'
ContractExecution = require './ContractExecution'
ContractTemplate = require './ContractTemplate'
prettyjson = require 'prettyjson'

class SetupClient

  constructor: (opts) ->
    @g = opts.graph
    @clientIdentity = opts.clientIdentity.uuid

  getWorkerId: () =>
    @clientIdentity

  setup: () ->

    console.log '--help for command reference'

    program.usage('testwork <server ip address> <server port>').command('testwork <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'send test work event'
      workerId = @getWorkerId()
      await @sendTestWorkEvent workerId, serverIp, serverPort

    # Deploy a ContractPen contract to an Accord Project folder structure
    program.usage('template <input json file> <directory of project>').command('template <input json file> <directory of project>').action (inputJsonFile, directory, cmd) =>
      console.log 'template ' + inputJsonFile + ' directory ' + directory
      await @templateProcess inputJsonFile, directory

    # Deploy a ContractPen contract to an Accord Project folder structure
    program.usage('deploy <guid> <dir>').command('deploy <guid> <dir>').action (guid, directoryToCreate, cmd) =>
      console.log 'deploying guid ' + guid
      console.log 'to directory ' + directoryToCreate
      @deploy guid, directoryToCreate

    program.usage('export <dir> <to json file>').command('export <dir> <to json file>').action (directory, jsonFile, cmd) =>
      console.log 'extract single directory to json file'
      json = await @extract directory, jsonFile, false
      @createFile jsonFile, JSON.stringify(json)

    # Extract JSON from Cicero projects
    program.usage('exportmulti <dir> <to json file>').command('exportmulti <dir> <to json file>').action (directory, jsonFile, cmd) =>
      console.log 'extract multiple directory to json file'
      json = await @extract directory, jsonFile, true
      @createFile jsonFile, JSON.stringify(json)

    program.usage('execute <dir>').command('execute <dir>').action (directory, cmd) =>
      console.log 'execute cicero'
      result = await @execute directory
      console.log result

    # Subscribe to server to await work events
    program.usage('subscribe <server ip address> <server port>').command('subscribe <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'subscribe, attempting to subscribe to server for work'
      console.log 'attempting ' + serverIp + ':' + serverPort
      await @subscribeCluster serverIp, serverPort

    program.parse process.argv

  deploy: (guid, directoryToCreate) =>
    contractJson = await @fetchContractJsonFromServer guid
    await @createProject directoryToCreate, contractJson

  templateProcess: (inputJsonFile, directory) =>
    t = new ContractTemplate()
    await t.template(inputJsonFile, directory)

  extract: (directory, jsonFile, isMulti) =>
    meta = new ContractMetadata()
    if isMulti
      i = await meta.iterateFoldersInDirectory directory
    else
      i = await meta.singleDirectory directory

    c = await meta.directoriesToJson i
    m = await meta.metaDataOfDirectoriesJson c
    m

    #m = await meta.metaDataOfProject 'C:\\home\\projects\\accord\\cicero-template-library\\src\\fragile-goods'
    #console.log m
    #console.log 'collected all metadata'
    #console.log c
    # structure of c is [project_path, cto_paths: [ctoPath, json]]
    #console.log 'finished extract'

  execute: (directory) =>
    console.log 'try execute'
    templatePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate'
    samplePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\sample.txt'
    requestsPath = ['C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\request.json']
    statePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\state.json'
    exec = new ContractExecution()
    exec.execute(templatePath, samplePath, requestsPath, statePath)

  # Submit test task to the server
  sendTestWorkEvent: (workerId, serverId, port) ->
    workData =
      fromWorkerId: workerId
      targetWorkerId: null
      sendResultToWorkerId: null
      command: 'deploy'
      params: ['b03d0879-1545-4ce9-bd08-7915457ce92c', 'testcicerofolder']

    request.post {
      url: "http://#{serverId}:#{port}/api/submitTask"
      body: workData
      json: true
    }, (error, response, body) ->
      if error
        return console.error('failed to send work test event:', error)
      console.log 'Upload successful!  Server responded with:', body
      return


    #request.post "http://#{serverId}:#{port}/api/submitTask", { json: true }, (err, res, body) ->
    #  if err
    #    return console.log(err)
    #  console.log body
    #  return

  subscribeCluster: (serverId, port) =>
    socket = new ClusterWS(url: 'ws://localhost:3050')

    # Client must execute the job as given from the server and reply the result back to the server
    socket.on 'executeJob', (job) =>
      console.log 'execute job called from the server'
      job = JSON.parse(job)

      if (job.command == 'deploy')
        console.log 'deploying contract ' + job.params[0] + ' ' + job.params[1]
        @deploy job.params[0], job.params[1]
        socket.send 'finishedJob',
          workerId: @getWorkerId()
          job: job
          result: 'unknown'
      return

    # When the server is connected we send back to the server that we are ready to accept commands
    socket.on 'serverConnected', (data) =>
      console.log 'Server called back, that means we can accept a command from the server'
      socket.send 'clientReadyToAcceptCommands', @getWorkerId()
      # your code to execute on event
      return

    # executed when client is connected to the server
    socket.on 'connect', ->
      console.log 'connected websocket clusterws'
      # your code to execute on connect event
      return
    # executed when error has happened
    socket.on 'error', (err) ->
      # your code to execute on error event
      return
    # executed when client is disconnected from the server
    socket.on 'disconnect', (code, reason) ->
      # your code to execute on disconnect event
      return
    return

  doNothing: (error) -> 0

  idName: (name) -> name.trim().split(' ').join('_').toLowerCase()

  # Executes all handlebars templates and places them in the destination directory
  createProject: (dir, contract) =>
    @createDirectoryIfNotExist dir
    @createDirectoryIfNotExist dir + path.sep + 'grammar'
    @createDirectoryIfNotExist dir + path.sep + 'lib'
    @createDirectoryIfNotExist dir + path.sep + 'models'
    @createDirectoryIfNotExist dir + path.sep + 'test'
    @createFile dir + path.sep + 'package.json', @template('package.json.hbs', {projectName: @idName(contract.contract.name)})
    @createFile dir + path.sep + 'README.md', @template('README.md.hbs', {})
    @createFile dir + path.sep + 'request.json', @template('request.json.hbs', {})
    @createFile dir + path.sep + 'sample.txt', @template('sample.txt.hbs', {})
    @createFile dir + path.sep + 'state.json', @template('state.json.hbs', {})
    @createFile dir + path.sep + 'test' + path.sep + 'logic.js', @template('logic.js.hbs', {})
    @createFile dir + path.sep + 'grammar' + path.sep + 'template.tem', @template('template.tem.hbs', {})
    @createFile dir + path.sep + 'lib' + path.sep + 'logic.ergo', @template('logic.ergo.hbs', {})
    @createFile dir + path.sep + 'models' + path.sep + 'model.cto', @template('model.cto.hbs', {dataModels: contract.contract.dataModels})

  # Executes the handlebars template with the data as given
  template: (file, data) ->
    root = path.dirname(require.main.filename)
    file = fs.readFileSync(root + path.sep + 'handlebars' + path.sep + file, 'utf8')
    template = Handlebars.compile(file)
    result = template({data: data}) # result = template({data: d})
    result

  # Creates a file with this contents, the string template
  createFile: (file, template) ->
    fs.writeFileSync file, template,
      encoding: 'utf8'
      flag: 'w'

  createDirectoryIfNotExist: (dir) ->
    try
      fs.mkdirSync dir
    catch e
      @doNothing e

  # Constructs a GraphlQL query and then executes that query on api.contractpen.com GraphQL API endpoint.
  # You may use this URL to test GraphQL queries http://api.contractpen.com/graphQl
  fetchContractJsonFromServer: (guid) ->
    query = """
    query {
      contract(uuid: "#{guid}") {
        name
        dataModels {
          ciceroClassName
          ciceroNameSpace
          ciceroExtendsClass
          ciceroAssetOrTransaction
          fields {
            fieldName
            dataType
            dropDownDataType
          }
        }
      }
    }
    """
    await graphQlRequest.request 'http://api.contractpen.com/graphQl', query

module.exports = SetupClient


