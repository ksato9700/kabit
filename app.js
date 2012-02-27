(function() {
  var app, display_sockets, express, io, port, socketio;

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

  port = process.env.PORT || 3000;

  app.listen(port, function() {
    return console.log("Listening on " + port);
  });

  io = socketio.listen(app);

  display_sockets = [];

  io.sockets.on('connection', function(socket) {
    socket.emit('ready');
    socket.on('display', function() {
      return display_sockets.push(socket);
    });
    return socket.on('device', function(display) {
      socket.on('location', function(data) {});
      socket.on('battery', function(data) {});
      socket.on('deviceorientation', function(data) {
        var ds, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = display_sockets.length; _i < _len; _i++) {
          ds = display_sockets[_i];
          _results.push(ds.emit('deviceorientation', socket.id, data));
        }
        return _results;
      });
      socket.on('touchstart', function(data) {
        var ds, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = display_sockets.length; _i < _len; _i++) {
          ds = display_sockets[_i];
          _results.push(ds.emit('touchstart', socket.id, data));
        }
        return _results;
      });
      socket.on('touchmove', function(data) {
        var ds, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = display_sockets.length; _i < _len; _i++) {
          ds = display_sockets[_i];
          _results.push(ds.emit('touchmove', socket.id, data));
        }
        return _results;
      });
      return socket.on('touchend', function(data) {
        var ds, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = display_sockets.length; _i < _len; _i++) {
          ds = display_sockets[_i];
          _results.push(ds.emit('touchend', socket.id, data));
        }
        return _results;
      });
    });
  });

}).call(this);
