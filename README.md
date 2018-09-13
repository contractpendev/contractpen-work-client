
## ContractPen Node Service

Client programs calls across to api.contractpen.com. This program allows programmers using NodeJS to deploy ContractPen contracts to the accord project specification and will later allow for deploying the contract to the blockchain.

To compile coffeescript

npm run compile

### ContractPen

ContractPen is a simple web user interface designed to allow people eventually to deploy legal contracts to the blockchain. The current goal is to integrate ContractPen.com with the Accord Project https://www.accordproject.org/ as this project allows legal contract clauses to execute on the blockchain.

### Open Source

Although ContractPen.com is currently closed source, it may become open source in the future. So in that spirit it is useful to encourage open source around the ContractPen API's and integration with other open source projects such as Accord Project.

I encourage you to build open source software around the legaltech software and integration with ContractPen data API's.

### Required software

1. NodeJS v10.7.0 is the version I am using.

2. Accord Cicero and Accord Ergo by installing.

```
npm install -g @accordproject/cicero-cli
npm install -g @accordproject/ergo-cli
```

From these packages

https://www.npmjs.com/package/@accordproject/cicero-cli

https://www.npmjs.com/package/@accordproject/ergo-cli

3. Coffeescript as the coffee command https://coffeescript.org/

### Creating a Cicero NodeJS program

Cicero project is a Accord Project library, the purpose of this client contractpen_node_client is to allow a ContractPen.com Contracts data to be deployed to a Cicero NodeJS project.

This will take the data models as defined in the ContractPen contract and generate the Cicero data models as files with the extension of .cto in the models directory. Models are defined in the Models menu section of a ContractPen contract.

To run On Windows to deploy a ContractPen contract to a Cicero folder. This first parameter is the GUID of the contract at ContractPen, you can find that in the URL of the contract itself. There is a run.bat batch file.

run deploy b03d0879-1545-4ce9-bd08-7915457ce92c cicerofolder

This will create a folder called cicerofolder and generates a NodeJS project inside this folder. cicerofolder can be any folder name. The project will be similar to the Cicero HelloWorld project here https://github.com/accordproject/cicero-template-library/tree/master/src/helloworld 

cd cicerofolder

In this folder you should be able to execute the following without errors.

```
npm install
cicero parse --template . --dsl sample.txt
cicero execute
```

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


