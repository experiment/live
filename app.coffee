express = require 'express'
routes = require './routes'
http = require 'http'
path = require 'path'
redis = require 'redis'

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

http.createServer(app).listen app.get('port'), ->
  console.log 'Express server listening on port ' + app.get('port')

redis_conf =
  host: process.env.REDIS_HOST
  port: process.env.REDIS_PORT
  auth: null

client = redis.createClient redis_conf.port, redis_conf.host
if redis_conf.auth
  client.auth redis_conf.auth

client.on 'ready', ->
  client.subscribe 'codes'

client.on 'message', (_, code) ->
  console.log code
