events = require 'events'
redis = require 'redis'

class Redis extends events.EventEmitter
  constructor: (config) ->
    @client = redis.createClient config.port, config.host
    @client.auth config.password
    @_subscribe()

  _subscribe: ->
    @client.subscribe 'codes'
    @client.on 'message', (_, code) =>
      @emit 'code', code

exports.Redis = Redis;
