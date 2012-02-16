(function() {
  var KController, compare_array, kc;

  compare_array = function(a, b) {
    var i, _ref;
    if (a.length !== b.length) return false;
    for (i = 0, _ref = a.length; 0 <= _ref ? i < _ref : i > _ref; 0 <= _ref ? i++ : i--) {
      if (a[i] !== b[i]) return false;
    }
    return true;
  };

  KController = (function() {

    function KController(host_url) {
      this.socket = io.connect(host_url);
    }

    KController.prototype.sense = function() {
      var _this = this;
      return this.socket.on('ready', function() {
        _this.display = 0;
        _this.socket.emit('device');
        _this.orientation = [0, 0, 0];
        _this.calibration();
        return _this.sense_orientation();
      });
    };

    KController.prototype.sense_location = function() {
      var watchId,
        _this = this;
      watchId = navigator.geolocation.watchPosition(function(position) {
        return _this.socket.emit('location', {
          timestamp: position.timtstamp,
          latitude: position.coords.latitude,
          longitude: position.coords.longitude,
          altitude: position.coords.altitude,
          accuracy: position.coords.accuracy,
          altitudeAccuracy: position.coords.altitudeAccuracy,
          heading: position.coords.heading,
          speed: position.coords.speed
        });
      });
      return this.socket.on('disconnect', function() {
        return navigator.geolocation.clearWatch(watchId);
      });
    };

    KController.prototype.sense_battery = function() {
      var battery;
      battery = navigator.battery || navigator.mozBattery || navigator.webkitBattery;
      return this.socket.emit('battery', {
        charging: navigator.battery.charging,
        chargingTime: navigator.battery.chargingTime,
        level: navigator.battery.level,
        dischargingTime: navigator.battery.dischargingTime
      });
    };

    KController.prototype.sense_orientation = function() {
      var _this = this;
      return addEventListener('deviceorientation', function(event) {
        var didnt_change, orientation, val;
        orientation = (function() {
          var _i, _len, _ref, _results;
          _ref = [event.alpha, event.beta, event.gamma];
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            val = _ref[_i];
            _results.push(Math.round(val));
          }
          return _results;
        })();
        didnt_change = compare_array(orientation, _this.orientation);
        if (!didnt_change) {
          _this.socket.emit('deviceorientation', orientation);
          return _this.orientation = orientation;
        }
      });
    };

    KController.prototype.calibration = function() {
      return addEventListener('compassneedscalibration', function(event) {
        console.log('Your compass needs calibrating! Wave your device in a figure-eight motion');
        return event.preventDefault();
      }, true);
    };

    return KController;

  })();

  kc = new KController(window.host_url);

  kc.sense();

}).call(this);
