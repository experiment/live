events = require 'events'
redis = require 'redis'

class Redis extends events.EventEmitter
  constructor: (config) ->
    @sub_client = @_connect config
    @cmd_client = @_connect config
    @_subscribe()
    @on 'newListener', -> @_emit_current_set()

  _connect: (config) ->
    client = redis.createClient config.port, config.host
    client.auth config.password
    client

  _emit_current_set: ->
    @cmd_client.lrange 'hits', 0, 100, (err, resp) =>
      @emit 'hits', resp

  _subscribe: ->
    @sub_client.subscribe 'hits'
    @sub_client.on 'message', (_, hit) =>
      @emit 'hit', hit

exports.Redis = Redis;
