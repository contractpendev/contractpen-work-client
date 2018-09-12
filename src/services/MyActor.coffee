
class MyActor

  constructor: (opts) ->
    console.log 'hi'

  sayHello: (to) ->
    console.log "Hello, #{to}!"

module.exports = MyActor
