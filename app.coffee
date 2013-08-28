express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
socket_io = require 'socket.io'
NewRelicApi = require 'newrelicapi'
_ = require 'underscore'
moment = require 'moment'

Redis = require('./lib/redis.coffee').Redis

redis_conf =
  host: process.env.REDIS_HOST
  port: process.env.REDIS_PORT
  auth: process.env.REDIS_PASSWORD

new_relic_conf=
  apikey: process.env.NEW_RELIC_API_KEY
  accountId: process.env.NEW_RELIC_ID
  app_id: 7821

app = express();

# all environments
app.set 'port', process.env.PORT || 3000
app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'
app.use express.favicon()
app.use express.logger('dev')
app.use express.bodyParser()
app.use express.methodOverride()
app.use app.router
app.use require('stylus').middleware(__dirname + '/public')
app.use express.static(path.join(__dirname, 'public'))

# development only
if app.get('env') == 'development'
  app.use express.errorHandler()

app.get('/', routes.index);

server = http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')

io = socket_io.listen server

# connect to new relic
newrelic = new NewRelicApi new_relic_conf

# connect to redis
redis = new Redis
  host: redis_conf.host
  port: redis_conf.port
  password: redis_conf.auth

io.sockets.on 'connection', (socket) ->

  # push status codes
  redis.on 'code', (code) -> socket.emit 'code', { code: code }

  # backend response time
  newrelic.getSummaryMetrics new_relic_conf.app_id, (err, metrics) ->
    response_time = _.findWhere metrics, name: 'Response Time'
    socket.emit 'new_relic', be_response_time: response_time.metric_value

  # fontend response time
  newrelic.getMetrics {
    appId: new_relic_conf.app_id
    metrics: ['EndUser']
    field: 'average_fe_response_time'
    begin: moment().subtract('minute', 1).toISOString()
    end: moment().toISOString()
  }, (err, metrics) ->
    socket.emit 'new_relic', fe_response_time: metrics[0].average_fe_response_time


  socket.on 'disconnect', -> client.quit()
