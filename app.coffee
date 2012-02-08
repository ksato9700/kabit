express = require 'express'
socketio = require 'socket.io'

app = express.createServer express.logger()
app.use express.static __dirname

port = 8080
app.listen port, ->
  console.log "Listening on " + port

io = socketio.listen app

io.sockets.on 'connection', (socket)->
  socket.emit 'ready'

  socket.on 'location', (data)->
    console.log data
