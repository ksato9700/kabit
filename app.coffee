#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
# 
express = require 'express'
socketio = require 'socket.io'

routes = require './routes'

app = express()

app.configure ->
  app.set 'port', process.env.PORT || 3000
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
  app.use express.favicon()
  app.use express.logger 'dev'
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
  app.use express.static __dirname + '/public'

app.get '/', routes.index
app.get '/:type', routes.type

port = process.env.PORT || 3000
server = app.listen port, ->
  console.log "Listening on #{port}"

io = socketio.listen server

server = io.sockets.on 'connection', (client)->
  server.emit 'connected'
  client.on 'join', (req)->
    client.join req.type
    console.log 'joined type:', req.type
    server.to(req.type).emit 'hello', 'all'
    
  #   server.on 'location', (data)->
  #     #console.log "LOCATION-->", data

  client.on 'battery', (data)->
    console.log "BATTERY-->", data
    server.to('displays').emit 'battery', client.id, data

  client.on 'deviceorientation', (data)->
    # console.log data
    server.to('displays').emit 'deviceorientation', client.id, data

  #   server.on 'touchstart', (data)->
  #     ds.emit 'touchstart', server.id, data for ds in display_servers

  #   server.on 'touchmove', (data)->
  #     ds.emit 'touchmove', server.id, data for ds in display_servers

  #   server.on 'touchend', (data)->
  #     ds.emit 'touchend', server.id, data for ds in display_servers
