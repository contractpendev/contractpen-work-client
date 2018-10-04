fs = require('fs')

testTemplate = require('../test_template.json')
setup = require('../src/Setup')

describe 'SetupClient', ->
  setupClient = setup.container.resolve('SetupClient')

  it 'resolves OK', ->
    expect(setupClient).not.toBeUndefined()
    expect(typeof setupClient.getWorkerId()).toBe('string')

  describe 'clauseProcess', ->
    it 'processes valid input data A', ()->
      data = JSON.stringify(testTemplate)
      spyOn(fs, 'readFile').and.callFake (fileName, fileEncoding, callback) -> callback(null, data)

      result = await setupClient.clauseProcess('fileName')
      expect(result).toEqual(testTemplate)

    it 'handles error raised given non-existent file', ()->
      err = new Error('ENOENT')
      spyOn(fs, 'readFile').and.callFake (fileName, fileEncoding, callback) -> callback(err, null)

      setupClient.clauseProcess('fileName').catch (err) ->
        expect(err).not.toBeUndefined()
        expect(err.message).toEqual('Failed reading fileName: Error: ENOENT')

    it 'handles error raised given bad data', () ->
      spyOn(fs, 'readFile').and.callFake (fileName, fileEncoding, callback) -> callback(null, '{"$class": "$class"')

      setupClient.clauseProcess('fileName').catch (err) ->
        expect(err).not.toBeUndefined()
        expect(err.message).toEqual('Failed parsing clause from fileName: SyntaxError: Unexpected end of JSON input')

  describe 'templateProcess', ->
    beforeEach () ->
      spyOn(setupClient, 'clauseProcess').and.callFake (fileName) -> Promise.resolve(testTemplate)

    it 'processes valid input data', ()->
      data = 'clauseText'
      spyOn(console, 'info')
      spyOn(setupClient.container, 'resolve').and.callFake () ->
        template: (jsonData, grammar, directory) -> Promise.resolve(data)

      result = await setupClient.templateProcess('fileName', null, 'directory')
      expect(result).toBeUndefined()
      resultText = console.info.calls.argsFor(0)[0]
      expect(resultText).toEqual(data)

    it 'processes valid input data and handles error raised making a template', ()->
      err = 'Failed to find package.json'
      spyOn(console, 'error')
      spyOn(setupClient.container, 'resolve').and.callFake () ->
        template: (jsonData, grammar, directory) -> Promise.reject(err)

      result = await setupClient.templateProcess('fileName', null, 'directory')
      expect(result).toBeUndefined()
      resultErr = console.error.calls.argsFor(0)[0]
      expect(resultErr).toEqual(err)
