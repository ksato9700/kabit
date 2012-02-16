express = require 'express'
socketio = require 'socket.io'

app = express.createServer express.logger()
app.use express.static __dirname

app.configure ->
  app.set 'views', __dirname + '/views'

app.get '/controller', (req, res)->
  res.render "controller.ejs"
    host_url: "http://" + req.headers.host

app.get '/display', (req, res)->
  res.render "display.ejs"
    host_url: "http://" + req.headers.host

port = process.env.PORT || 3000
app.listen port, ->
  console.log "Listening on #{port}"

io = socketio.listen app

display_sockets = []

io.sockets.on 'connection', (socket)->
  socket.emit 'ready'

  socket.on 'display', ->
    display_sockets.push socket

  socket.on 'device', (display) ->
    socket.on 'location', (data)->
      #console.log "LOCATION-->", data

    socket.on 'battery', (data)->
      #console.log "BATTERY-->", data

    socket.on 'deviceorientation', (data)->
      ds.emit 'deviceorientation', socket.id, data for ds in display_sockets
