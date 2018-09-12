
Entities = require('html-entities').AllHtmlEntities
Handlebars = require 'handlebars'
helpers = require('handlebars-helpers')(handlebars: Handlebars)
express = require 'express'
bodyParser = require 'body-parser'
fs = require 'fs'
graphQlRequest = require 'graphql-request'
program = require 'commander'
path = require 'path'

class SetupClient

  constructor: (opts) ->
    @g = opts.graph

  setup: () ->
    program.usage('deploy <guid> <dir>').command('deploy <guid> <dir>').action (guid, directoryToCreate, cmd) =>
      console.log 'deploying guid ' + guid
      console.log 'to directory ' + directoryToCreate
      contractJson = await this.fetchContractJsonFromServer guid
      this.createProject directoryToCreate, contractJson

    program.parse process.argv

  doNothing: (error) -> 0

  idName: (name) -> name.trim().split(' ').join('_').toLowerCase()

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

  template: (file, data) ->
    root = path.dirname(require.main.filename)
    file = fs.readFileSync(root + path.sep + 'handlebars' + path.sep + file, 'utf8')
    template = Handlebars.compile(file)
    result = template({data: data}) # result = template({data: d})
    result

  createFile: (file, template) ->
    fs.writeFileSync(file, template)

  createDirectoryIfNotExist: (dir) ->
    try
      fs.mkdirSync dir
    catch e
      this.doNothing e

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
    await graphQlRequest.request 'http://localhost:4000/graphQl', query

module.exports = SetupClient


