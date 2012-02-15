express = require 'express'
socketio = require 'socket.io'

app = express.createServer express.logger()
app.use express.static __dirname

app.get '/controller', (req, res)->
  res.render "controller.ejs"
    host_url: "http://" + req.headers.host

port = 8080
app.listen port, ->
  console.log "Listening on " + port

io = socketio.listen app

io.sockets.on 'connection', (socket)->
  socket.emit 'ready'

  socket.on 'location', (data)->
    console.log "LOCATION-->", data

  socket.on 'battery', (data)->
    console.log "BATTERY-->", data

  socket.on 'deviceorientation', (data)->
    console.log "DEVICE ORIENTATION-->", data

