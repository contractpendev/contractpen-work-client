
Comedy = require 'comedy'
Awilix = require 'awilix'
Winston = require 'winston'
Graph = require '@dagrejs/graphlib'

graphClass = Graph.Graph
graphInstance = new graphClass()

# Logging
logger = Winston.createLogger(transports: [
  new (Winston.transports.File)(filename: 'application.log')
])

logger.log('info', 'Startup')

# Setup
actorSystem = Comedy()
actorSystem.getLog().setLevel(0)

# Dependency injection
container = Awilix.createContainer
  injectionMode: Awilix.InjectionMode.PROXY

container.register
  logger: Awilix.asValue logger
  actorSystem: Awilix.asValue actorSystem
  graphClass: Awilix.asClass graphClass
  graph: Awilix.asValue graphInstance

opts = {}

container.loadModules [
  'src/services/*.js'
], opts

module.exports = {container: container}
