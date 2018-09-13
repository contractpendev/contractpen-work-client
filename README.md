
## ContractPen Node Service

Client programs calls across to api.contractpen.com. This program allows programmers using NodeJS to deploy ContractPen contracts to the accord project specification and will later allow for deploying the contract to the blockchain.

To compile coffeescript

npm run compile

### Creating a Cicero NodeJS program

Cicero project is a Accord Project library, the purpose of this client contractpen_node_client is to allow a ContractPen.com Contracts data to be deployed to a Cicero NodeJS project.

To run On Windows to deploy a ContractPen contract to a Cicero folder. This first parameter is the GUID of the contract at ContractPen. There is a run.bat batch file.

run deploy 7e472861-4420-4c24-8728-6144201c241d cicerofolder

This will create a folder called cicerofolder and generates a NodeJS project inside this folder. cicerofolder can be any folder name. The project will be similar to the Cicero HelloWorld project here https://github.com/accordproject/cicero-template-library/tree/master/src/helloworld 

cd cicerofolder 

npm install



### About the code

The main class is SetupClient.coffee in src/services directory. 

You can see it is referenced in EntryPoint.coffee as

```
start = ->
  setupServer = Setup.container.resolve 'SetupClient'
  setupServer.setup()
```

### Libraries used

Some libraries are in use to try to help development within NodeJS.

Dependency injection

https://github.com/jeffijoe/awilix

Graph library which is not really used in this project but is added

https://github.com/dagrejs/graphlib/wiki


