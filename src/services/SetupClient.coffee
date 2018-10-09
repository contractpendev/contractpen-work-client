
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
zipIt = require('zip-a-folder')
read = require('fs-readdir-recursive')
memoize = require("memoizee")

class SetupClient

  constructor: (opts) ->
    @g = opts.graph
    @clientIdentity = opts.clientIdentity.uuid
    @container = opts.container
    @baseTemplateDirectory = opts.baseTemplateDirectory

  getWorkerId: () =>
    @clientIdentity

  setup: () ->

    console.log '--help for command reference'

    program.usage('testwork <server ip address> <server port>').command('testwork <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'send test work event'
      workerId = @getWorkerId()
      await @sendTestWorkEvent workerId, serverIp, serverPort

    program.usage('testwork2 <server ip address> <server port>').command('testwork2 <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'send test work event'
      workerId = @getWorkerId()
      await @sendTestWorkEvent2 workerId, serverIp, serverPort

    # ?
    program.usage('template <input json file> <directory of project>').command('template <input json file> <directory of project>').action (inputJsonFile, directory, cmd) =>
      console.log 'template ' + inputJsonFile + ' directory ' + directory
      jsonData = JSON.parse(fs.readFileSync(inputJsonFile, 'utf8'))
      await @templateProcess jsonData, null, directory

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

    program.usage('execute <dir> <sample txt file> <request file> <state file>').command('execute <dir> <sample txt file> <request path> <state path>').action (directory, sampleTxtFile, requestFile, stateFile, cmd) =>
      console.log 'execute cicero'
      result = await @execute directory, sampleTxtFile, requestFile, stateFile
      console.log result

    program.usage('execute2 <folder>').command('execute2 <folder>').action (folder) =>
      console.log 'execute2 cicero'
      result = await @execute2 folder
      console.log result

    program.usage('zip <folder>').command('zip <folder>').action (folder, cmd) =>
      console.log 'zip folder ' + folder
      @zipFolder folder

    program.usage('directorytree <folder>').command('directorytree <folder>').action (folder, cmd) =>
      @directoryTree folder

    program.usage('filecontents <path>').command('filecontents <path>').action (path, cmd) =>
      @fileContents path

    program.usage('cicerotemplates <path>').command('cicerotemplates <path>').action (path, cmd) =>
      @ciceroTemplates path

    # Subscribe to server to await work events
    program.usage('subscribe <server ip address> <server port>').command('subscribe <server ip address> <server port>').action (serverIp, serverPort, cmd) =>
      console.log 'subscribe, attempting to subscribe to server for work'
      console.log 'attempting ' + serverIp + ':' + serverPort
      await @subscribeCluster serverIp, serverPort

    program.parse process.argv

  deploy: (guid, directoryToCreate) =>
    dir = @baseTemplateDirectory + directoryToCreate
    contractJson = await @fetchContractJsonFromServer guid
    await @createProject dir, contractJson

  templateProcess: (jsonData, grammar, directory) =>
    try
      t = @container.resolve "ContractTemplate"
      dir = @baseTemplateDirectory + directory
      await t.template(jsonData, grammar, dir)
    catch e
      ''
  _extractFunction = (directory2, isMulti2) =>
    console.log 'extract! with directory ' + directory2
    meta = new ContractMetadata()
    if isMulti2
      i = await meta.iterateFoldersInDirectory directory2
    else
      i = await meta.singleDirectory directory2

    c = await meta.directoriesToJson i
    m = await meta.metaDataOfDirectoriesJson c
    m

  _memoizeExtractFunction = memoize _extractFunction

  extract: (directory, jsonFile, isMulti) =>
    try
      _memoizeExtractFunction directory, isMulti
    catch e
      console.log e
      ''

    #m = await meta.metaDataOfProject 'C:\\home\\projects\\accord\\cicero-template-library\\src\\fragile-goods'
    #console.log m
    #console.log 'collected all metadata'
    #console.log c
    # structure of c is [project_path, cto_paths: [ctoPath, json]]
    #console.log 'finished extract'

  #templatePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate'
  #samplePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\sample.txt'
  #requestsPath = ['C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\request.json']
  #statePath = 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworldstate\\state.json'
  execute: (templatePath, samplePath, requestPath, statePath) =>
    try
      console.log 'try execute!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      console.log templatePath
      console.log samplePath
      console.log requestPath
      console.log statePath
      exec = new ContractExecution()
      exec.execute(templatePath, samplePath, requestPath, statePath)
    catch e
      ''

  execute2: (folder) =>
    try
      base = @baseTemplateDirectory
      f = base + folder
      templatePath = f
      samplePath = f + path.sep + 'sample.txt'
      requestPath = [f + path.sep + 'request.json']
      statePath = f + path.sep + 'state.json'
      console.log 'try execute2!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
      console.log templatePath
      console.log samplePath
      console.log requestPath
      console.log statePath
      exec = new ContractExecution()
      exec.execute(templatePath, samplePath, requestPath, statePath)
    catch e
      ''

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


  sendTestWorkEvent2: (workerId, serverId, port) ->
    workData =
      fromWorkerId: workerId
      targetWorkerId: null
      sendResultToWorkerId: null
      command: 'template'
      params: ['test_template.json', 'C:\\home\\projects\\accord\\cicero-template-library\\src\\helloworld']

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

  commandSwitcher: (command, params) =>
    console.log 'commandSwitcher'
    result = null
    if (command == 'deploy')
      result = @deploy params[0], params[1]
    if (command == 'execute')
      result = @execute params[0], params[1], params[2], params[3]
    if (command == 'execute2')
      result = @execute2 params[0]
    if (command == 'template')
      console.log ''
      console.log ''
      console.log ''
      console.log 'at template'
      console.log params[0]
      console.log JSON.parse(params[0])
      j = JSON.parse(params[0])
      result = await @templateProcess j, params[1], params[2] # @todo Should JSON.parse be here?
    if (command == 'export')
      result = @extract params[0], ''
    if (command == 'exportmulti')
      result = @export params[0], params[1]
    if (command == 'zip')
      result = @zipFolder params[0]
    if (command == 'directorytree')
      result = @directoryTree params[0]
    if (command == 'filecontents')
      result = @fileContents params[0]
    if (command == 'cicerotemplates')
      result = @ciceroTemplates params[0]
    console.log 'result back'
    console.log result
    result

  directoryTree: (folder) =>
    try
      base = @baseTemplateDirectory
      f = base + folder
      dir = read(f)
      dirFixed = dir.map (m) -> m.replace(/\\/, "/")
      console.log 'directory tree is:'
      console.log dirFixed
      dirFixed
    catch e
      []

  fileContents: (path) =>
    try
      console.log 'file contents start'
      base = @baseTemplateDirectory
      file = fs.readFileSync(base + path, 'utf8')
      console.log 'file contents'
      file
    catch ex
      ''

  ciceroTemplates: (directoryPath) =>
    try
      console.log 'getting cicero template information'
      base = @baseTemplateDirectory

      # 1. Get all folders in C:\home\projects\accord\cicero-template-library\src
      dir =  path.sep + 'home' + path.sep + 'projects' + path.sep + 'accord' + path.sep + 'cicero-template-library' + path.sep + 'src'
      test = fs.readdirSync(dir, 'utf8')
      directories = []

      # 2. Read each README.md inside each folder
      for d in test
        dirToTest = dir + path.sep + d
        stat = fs.lstatSync(dirToTest)
        if stat.isDirectory()
          directories.push dirToTest

      readmes = directories.map (d) =>
        mydir = d + path.sep + 'package.json'
        fileContents = ''
        if fs.existsSync(mydir) then fileContents = fs.readFileSync(mydir, 'utf8')
        name = ''
        description = ''
        if fileContents.length > 0
          name = JSON.parse(fileContents).name
          description = JSON.parse(fileContents).description
        [d, name, description]

      # 3. Compose data to return and return back to caller
      readmesWithoutEmpty = readmes.filter (d) => d[1].length > 0
      readmesWithoutEmpty
    catch ex
      console.log ex
      ''

  zipFolder: (folder) =>
    try
      base = @baseTemplateDirectory
      f = base + folder
      a = base + folder + '.zip'
      await zipIt.zip(f, a)
    catch e
      null

  subscribeCluster: (serverId, port) =>
    socket = new ClusterWS(url: 'ws://localhost:3050')

    # Client must execute the job as given from the server and reply the result back to the server
    socket.on 'executeJob', (job) =>
      job = JSON.parse(job)
      console.log 'job command ' + job.command
      result = @commandSwitcher job.command, job.params
      result.then (r) =>
        console.log 'Promise finished and result is'
        console.log r

        # The result depends on the command
        # deploy: If the folder exists
        # execute: The result
        # template: The result is the text of the template result
        # export: The second parameter is the json file to return
        # exportMulti: The second parameter is the json file to return
        # directoryTree: Lists the directory tree under the path

        # If the directory exists then we say success
        workerId = @getWorkerId()
        socket.send 'finishedJob',
          workerId: workerId
          job: job
          result:
            job: job
            workerId: workerId
            returnResultFromFunctionExecution: r
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
    try
      console.log 'create project'
      console.log dir
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
    catch e
      e

  # Executes the handlebars template with the data as given
  template: (file, data) ->
    try
      root = path.dirname(require.main.filename)
      file = fs.readFileSync(root + path.sep + 'handlebars' + path.sep + file, 'utf8')
      template = Handlebars.compile(file)
      result = template({data: data}) # result = template({data: d})
      result
    catch e
      ''

  # Creates a file with this contents, the string template
  createFile: (file, template) ->
    try
      fs.writeFileSync file, template,
        encoding: 'utf8'
        flag: 'w'
    catch e
      null

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
    # http://api.contractpen.com/graphQl
    await graphQlRequest.request 'http://localhost:4000/graphQl', query

module.exports = SetupClient


