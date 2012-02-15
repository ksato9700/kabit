(function() {
  var app, display_socket, express, io, port, socketio;

  express = require('express');

  socketio = require('socket.io');

  app = express.createServer(express.logger());

  app.use(express.static(__dirname));

  app.configure(function() {
    return app.set('views', __dirname + '/views');
  });

  app.get('/controller', function(req, res) {
    return res.render("controller.ejs", {
      host_url: "http://" + req.headers.host
    });
  });

  app.get('/display', function(req, res) {
    return res.render("display.ejs", {
      host_url: "http://" + req.headers.host
    });
  });

  port = 8080;

  app.listen(port, function() {
    return console.log("Listening on " + port);
  });

  io = socketio.listen(app);

  display_socket = null;

  io.sockets.on('connection', function(socket) {
    socket.emit('ready');
    socket.on('display', function() {
      return display_socket = socket;
    });
    socket.on('location', function(data) {
      return console.log("LOCATION-->", data);
    });
    socket.on('battery', function(data) {
      return console.log("BATTERY-->", data);
    });
    return socket.on('deviceorientation', function(data) {
      return display_socket.emit('deviceorientation', data);
    });
  });

}).call(this);
