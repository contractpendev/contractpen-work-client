
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
request = require('request')

class SetupClient

  constructor: (opts) ->
    @g = opts.graph

  setup: () ->

    console.log '--help for command reference'

    program.usage('testwork <server ip address> <server port>').command('testwork <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'send test work event'
      await this.sendTestWorkEvent serverIp, serverPort

    # Deploy a ContractPen contract to an Accord Project folder structure
    program.usage('deploy <guid> <dir>').command('deploy <guid> <dir>').action (guid, directoryToCreate, cmd) =>
      console.log 'deploying guid ' + guid
      console.log 'to directory ' + directoryToCreate
      contractJson = await this.fetchContractJsonFromServer guid
      this.createProject directoryToCreate, contractJson

    # Subscribe to server to await work events
    program.usage('subscribe <server ip address> <server port>').command('subscribe <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'subscribe, attempting to subscribe to server for work'
      console.log 'attempting ' + serverIp + ':' + serverPort
      this.subscribeCluster serverIp, serverPort

    program.parse process.argv

  # Submit test task to the server
  sendTestWorkEvent: (serverId, port) ->
    workData =
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

  subscribeCluster: (serverId, port) ->
    socket = new ClusterWS(url: 'ws://localhost:3050')
    socket.on 'myeventname', (data) ->
      console.log 'hello'
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


  doNothing: (error) -> 0

  idName: (name) -> name.trim().split(' ').join('_').toLowerCase()

  # Executes all handlebars templates and places them in the destination directory
  createProject: (dir, contract) ->
    this.createDirectoryIfNotExist dir
    this.createDirectoryIfNotExist dir + path.sep + 'grammar'
    this.createDirectoryIfNotExist dir + path.sep + 'lib'
    this.createDirectoryIfNotExist dir + path.sep + 'models'
    this.createDirectoryIfNotExist dir + path.sep + 'test'
    this.createFile dir + path.sep + 'package.json', this.template('package.json.hbs', {projectName: this.idName(contract.contract.name)})
    this.createFile dir + path.sep + 'README.md', this.template('README.md.hbs', {})
    this.createFile dir + path.sep + 'request.json', this.template('request.json.hbs', {})
    this.createFile dir + path.sep + 'sample.txt', this.template('sample.txt.hbs', {})
    this.createFile dir + path.sep + 'state.json', this.template('state.json.hbs', {})
    this.createFile dir + path.sep + 'test' + path.sep + 'logic.js', this.template('logic.js.hbs', {})
    this.createFile dir + path.sep + 'grammar' + path.sep + 'template.tem', this.template('template.tem.hbs', {})
    this.createFile dir + path.sep + 'lib' + path.sep + 'logic.ergo', this.template('logic.ergo.hbs', {})
    this.createFile dir + path.sep + 'models' + path.sep + 'model.cto', this.template('model.cto.hbs', {dataModels: contract.contract.dataModels})

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
      this.doNothing e

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


