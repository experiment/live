_ = require 'underscore'
events = require 'events'
moment = require 'moment'
new_relic = require 'newrelicapi'

class NewRelic extends events.EventEmitter
  constructor: (config) ->
    @client = new new_relic
      accountId: config.account_id
      apikey: config.api_key
    @app_id = config.app_id
    @data = {}
    @_start_polling()
    @on 'newListener', -> @_emit()

  _start_polling: ->
    setInterval =>
      @_poll()
    , 60000
    @_poll()

  _save_and_emit: (key, value) ->
    @data[key] = value
    @_emit key, value

  _emit: ->
    @emit 'data', @data

  _poll: ->
    @_get_backend_response_time()
    @_get_front_end_response_time()

  _get_backend_response_time: ->
    @client.getSummaryMetrics @app_id, (err, metrics) =>
      response_time = _.findWhere metrics, name: 'Response Time'
      @_save_and_emit 'be_response_time', response_time.metric_value

  _get_front_end_response_time: ->
    @client.getMetrics {
      appId: @app_id
      metrics: ['EndUser']
      field: 'average_fe_response_time'
      begin: moment().subtract('minute', 1).toISOString()
      end: moment().toISOString()
    }, (err, metrics) =>
      @_save_and_emit 'fe_response_time', metrics[0].average_fe_response_time

exports.NewRelic = NewRelic;
