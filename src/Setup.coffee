
Comedy = require 'comedy'
Awilix = require 'awilix'
Winston = require 'winston'
Graph = require '@dagrejs/graphlib'
createIfNotExist = require 'create-if-not-exist'
uuidv1 = require 'uuid/v1'
fs = require('fs')
NodeCache = require( "node-cache" )
os = require('os')

baseTemplateDirectory = ''
if os.type() is 'Windows_NT'
  baseTemplateDirectory = '\\home\\projects\\contractpen_node_client\\templates\\'
else
if os.type() is 'Darwin'
  baseTemplateDirectory = '/Users/philipandrew/projects/contractpen_template_dir/'
else 
if os.type() is 'Linux'
  baseTemplateDirectory = '/root/template/'

nodeCache = new NodeCache()

clientIdentity =
  uuid: uuidv1()

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

# Register the dependency injection
container.register
  container: Awilix.asValue container
  logger: Awilix.asValue logger
  actorSystem: Awilix.asValue actorSystem
  graphClass: Awilix.asClass graphClass
  graph: Awilix.asValue graphInstance
  clientIdentity: Awilix.asValue clientIdentity
  nodeCache: Awilix.asValue nodeCache
  myCache: Awilix.asValue myCache
  baseTemplateDirectory: Awilix.asValue baseTemplateDirectory

opts = {}

container.loadModules [
  'src/services/*.js'
], opts

module.exports = {container: container}
