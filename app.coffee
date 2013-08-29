# npm dependencies
express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
socket_io = require 'socket.io'
_ = require 'underscore'

# lib dependencies
Redis = require('./lib/redis.coffee').Redis
NewRelic = require('./lib/new_relic.coffee').NewRelic

# config
redis_conf =
  host: process.env.REDIS_HOST
  port: process.env.REDIS_PORT
  auth: process.env.REDIS_PASSWORD

new_relic_conf=
  api_key: process.env.NEW_RELIC_API_KEY
  account_id: process.env.NEW_RELIC_ID
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

# configure socket.io
io = socket_io.listen server
io.configure ->
  io.set 'transports', ['xhr-polling']
  io.set 'polling duration', 10

# connect to new relic
newrelic = new NewRelic new_relic_conf

# connect to redis
redis = new Redis
  host: redis_conf.host
  port: redis_conf.port
  password: redis_conf.auth

# socket logic
io.sockets.on 'connection', (socket) ->

  # push hits
  redis.on 'hits', (hits) ->
    socket.emit 'hits', _.map hits, (hit) -> JSON.parse(hit)
  redis.on 'hit', (hit) ->
    socket.emit 'hit', JSON.parse(hit)

  # push newrelic stats
  newrelic.on 'data', (data) ->
    socket.emit 'new_relic', data
