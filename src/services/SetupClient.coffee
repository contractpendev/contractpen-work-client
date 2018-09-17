
Entities = require('html-entities').AllHtmlEntities
Handlebars = require 'handlebars'
helpers = require('handlebars-helpers')(handlebars: Handlebars)
express = require 'express'
bodyParser = require 'body-parser'
fs = require 'fs'
graphQlRequest = require 'graphql-request'
program = require 'commander'
path = require 'path'
WebSocketClient = require('websocket').client

class SetupClient

  constructor: (opts) ->
    @g = opts.graph

  setup: () ->

    program.usage('deploy <guid> <dir>').command('deploy <guid> <dir>').action (guid, directoryToCreate, cmd) =>
      console.log 'deploying guid ' + guid
      console.log 'to directory ' + directoryToCreate
      contractJson = await this.fetchContractJsonFromServer guid
      this.createProject directoryToCreate, contractJson

    program.usage('subscribe <server ip address> <server port>').command('subscribe <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'subscribe, attempting to subscribe to server for work'
      console.log 'attempting ' + serverIp + ':' + serverPort
      this.subscribeForWorkFromServerUsingWebsockets serverIp, serverPort

    program.parse process.argv




  subscribeForWorkFromServerUsingWebsockets: (serverIp, port) ->
    client = new WebSocketClient
    client.on 'connectFailed', (error) ->
      console.log 'Connect Error: ' + error.toString()
      return
    client.on 'connect', (connection) ->

    #sendNumber = ->
    #  if connection.connected
    #    number = Math.round(Math.random() * 0xFFFFFF)
    #    connection.sendUTF number.toString()
    #    setTimeout sendNumber, 1000
    #  return

      console.log 'WebSocket Client Connected'
      connection.on 'error', (error) ->
        console.log 'Connection Error: ' + error.toString()
        return
      connection.on 'close', ->
        console.log 'echo-protocol Connection Closed'
        return
      connection.on 'message', (message) ->
        if message.type == 'utf8'
          console.log 'Received: \'' + message.utf8Data + '\''
        return
      #sendNumber()
      return
    client.connect "ws://#{serverIp}:#{port}/", 'echo-protocol'

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


