(function() {
  var KDisplay, generate_sprite, kd;

  generate_sprite = function() {
    var canvas, context, gradient, half_ch, half_cw;
    canvas = document.createElement('canvas');
    canvas.width = 16;
    canvas.height = 16;
    context = canvas.getContext('2d');
    half_cw = canvas.width / 2;
    half_ch = canvas.height / 2;
    gradient = context.createRadialGradient(half_cw, half_ch, 0, half_cw, half_ch, half_cw);
    gradient.addColorStop(0, 'rgba(255,255,255,1)');
    gradient.addColorStop(0.2, 'rgba(0,255,255,1)');
    gradient.addColorStop(0.4, 'rgba(0,0,64,1)');
    gradient.addColorStop(1, 'rgba(0,0,0,1)');
    context.fillStyle = gradient;
    context.fillRect(0, 0, canvas.width, canvas.height);
    return canvas;
  };

  KDisplay = (function() {

    function KDisplay(host_url) {
      this.socket = io.connect(host_url);
      this.cubes = [];
      this.particles = [];
      this.devices = [];
    }

    KDisplay.prototype.display = function() {
      var _this = this;
      return this.socket.on('ready', function() {
        var timer;
        _this.socket.emit('display');
        _this.display_orientation();
        _this.display_touch();
        _this.three_init();
        timer = setInterval(function() {
          return _this.three_render();
        }, 16);
        return _this.socket.on('id', function(id) {
          return _this.id = id;
        });
      });
    };

    KDisplay.prototype.three_init = function() {
      var container, idx, _results;
      container = $('#container');
      this.scene = new THREE.Scene();
      this.camera = new THREE.PerspectiveCamera(90, window.innerWidth / window.innerHeight, 120, 10000);
      this.camera.position.y = 250;
      this.camera.position.z = 750;
      this.scene.add(this.camera);
      this.renderer = new THREE.CanvasRenderer();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      container.append(this.renderer.domElement);
      _results = [];
      for (idx = 0; idx < 4; idx++) {
        _results.push(this.create_cubes(idx));
      }
      return _results;
    };

    KDisplay.prototype.create_cubes = function(idx) {
      var cube, cube_face, cube_geometory, i, material, materials, particle, position_x;
      materials = (function() {
        var _results;
        _results = [];
        for (i = 0; i < 6; i++) {
          _results.push(new THREE.MeshBasicMaterial({
            color: Math.random() * 0xffffff
          }));
        }
        return _results;
      })();
      position_x = -720 + 480 * idx;
      cube_geometory = new THREE.CubeGeometry(240, 20, 320, 1, 1, 1, materials);
      cube_face = new THREE.MeshFaceMaterial();
      cube = new THREE.Mesh(cube_geometory, cube_face);
      cube.position.x = position_x;
      cube.position.y = 150;
      cube.rotation.set(1, 0, 0);
      cube.overdraw = true;
      this.scene.add(cube);
      this.cubes.push(cube);
      material = new THREE.ParticleBasicMaterial({
        map: new THREE.Texture(generate_sprite()),
        blending: THREE.AdditiveBlending
      });
      particle = new THREE.Particle(material);
      particle.scale.multiplyScalar(10);
      particle.visible = false;
      cube.add(particle);
      return this.particles.push(particle);
    };

    KDisplay.prototype.three_render = function() {
      return this.renderer.render(this.scene, this.camera);
    };

    KDisplay.prototype.get_idx = function(id) {
      var idx;
      idx = this.devices.indexOf(id);
      if (idx < 0) {
        if (this.devices.length >= 4) this.devices.shift();
        this.devices.push(id);
        idx = this.devices.length - 1;
      }
      return idx;
    };

    KDisplay.prototype.display_orientation = function() {
      var _this = this;
      return this.socket.on('deviceorientation', function(id, data) {
        var idx, rx, ry, rz;
        idx = _this.get_idx(id);
        rx = (parseInt(data[1])) / 57.3;
        ry = (parseInt(data[0])) / 57.3;
        rz = -(parseInt(data[2])) / 57.3;
        _this.cubes[idx].rotation.set(rx, ry, rz);
        return _this.cubes[idx].updateMatrixWorld(true);
      });
    };

    KDisplay.prototype.touch_action = function(id, data, visible) {
      var idx, x, y;
      idx = this.get_idx(id);
      if (visible) {
        x = 240 * data[0] - 120;
        y = 320 * data[1] - 160;
        this.particles[idx].visible = true;
        return this.particles[idx].position.set(x, 80, y);
      } else {
        return this.particles[idx].visible = false;
      }
    };

    KDisplay.prototype.display_touch = function(idx) {
      var _this = this;
      this.socket.on('touchstart', function(id, data) {
        return _this.touch_action(id, data, true);
      });
      this.socket.on('touchmove', function(id, data) {
        return _this.touch_action(id, data, true);
      });
      return this.socket.on('touchend', function(id, data) {
        return _this.touch_action(id, data, false);
      });
    };

    return KDisplay;

  })();

  kd = new KDisplay(window.host_url);

  kd.display();

}).call(this);
