
Comedy = require 'comedy'
Awilix = require 'awilix'
Winston = require 'winston'
Graph = require '@dagrejs/graphlib'
createIfNotExist = require 'create-if-not-exist'
uuidv1 = require 'uuid/v1'
fs = require('fs')
NodeCache = require( "node-cache" )

nodeCache = new NodeCache()

clientIdentity =
  uuid: uuidv1()
#createIfNotExist('./clientIdentity.json', JSON.stringify(clientIdentity))
#clientIdentity = JSON.parse(fs.readFileSync('./clientIdentity.json', 'utf8'))
#console.log 'client identity is ' + clientIdentity.uuid

graphClass = Graph.Graph
graphInstance = new graphClass()

# Logging
logger = Winston.createLogger(transports: [
  new (Winston.transports.File)(filename: 'application.log')
])

logger.log('info', 'Startup')

# Setup
actorSystem = Comedy()
actorSystem.getLog().setLevel(0) # Prevent output of log at startup

# Dependency injection
container = Awilix.createContainer
  injectionMode: Awilix.InjectionMode.PROXY

myCache = {}

container.register
  container: Awilix.asValue container
  logger: Awilix.asValue logger
  actorSystem: Awilix.asValue actorSystem
  graphClass: Awilix.asClass graphClass
  graph: Awilix.asValue graphInstance
  clientIdentity: Awilix.asValue clientIdentity
  nodeCache: Awilix.asValue nodeCache
  myCache: Awilix.asValue myCache

opts = {}

container.loadModules [
  'src/services/*.js'
], opts

module.exports = {container: container}
