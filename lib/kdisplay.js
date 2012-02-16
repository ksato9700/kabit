(function() {
  var KDisplay, kd;

  KDisplay = (function() {

    function KDisplay(host_url) {
      this.socket = io.connect(host_url);
      this.cubes = [];
      this.planes = [];
      this.devices = [];
    }

    KDisplay.prototype.display = function() {
      var _this = this;
      return this.socket.on('ready', function() {
        var timer;
        _this.socket.emit('display');
        _this.display_orientation();
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
      this.camera = new THREE.PerspectiveCamera(70, window.innerWidth / window.innerHeight, 100, 1000);
      this.camera.position.y = 150;
      this.camera.position.z = 500;
      this.scene.add(this.camera);
      this.renderer = new THREE.CanvasRenderer();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
      container.append(this.renderer.domElement);
      _results = [];
      for (idx = 0; idx < 4; idx++) {
        _results.push(this.create_cube_plane(idx));
      }
      return _results;
    };

    KDisplay.prototype.create_cube_plane = function(idx) {
      var cube, cube_face, cube_geometory, i, materials, plane, plane_geometry, plane_material, position_x;
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
      position_x = -300 + 200 * idx;
      cube_geometory = new THREE.CubeGeometry(100, 20, 200, 1, 1, 1, materials);
      cube_face = new THREE.MeshFaceMaterial();
      cube = new THREE.Mesh(cube_geometory, cube_face);
      cube.position.x = position_x;
      cube.position.y = 150;
      cube.overdraw = true;
      this.scene.add(cube);
      this.cubes.push(cube);
      plane_geometry = new THREE.PlaneGeometry(100, 200);
      plane_material = new THREE.MeshBasicMaterial({
        color: 0xe0e0e0
      });
      plane = new THREE.Mesh(plane_geometry, plane_material);
      plane.position.x = position_x;
      plane.rotation.x = -90 * (Math.PI / 180);
      plane.overdraw = true;
      this.scene.add(plane);
      return this.planes.push(plane);
    };

    KDisplay.prototype.three_render = function() {
      return this.renderer.render(this.scene, this.camera);
    };

    KDisplay.prototype.display_orientation = function() {
      var _this = this;
      return this.socket.on('deviceorientation', function(id, data) {
        var idx;
        idx = _this.devices.indexOf(id);
        if (idx < 0) {
          if (_this.devices.length >= 4) _this.devices.shift();
          _this.devices.push(id);
          idx = _this.devices.length - 1;
        }
        _this.cubes[idx].rotation.x = (parseInt(data[1])) / 57.3;
        _this.cubes[idx].rotation.y = (parseInt(data[0])) / 57.3;
        _this.cubes[idx].rotation.z = -(parseInt(data[2])) / 57.3;
        _this.planes[idx].rotation.x = (parseInt(data[1])) / 57.3 - 90 * (Math.PI / 180);
        _this.planes[idx].rotation.y = (parseInt(data[2])) / 57.3;
        _this.planes[idx].rotation.z = (parseInt(data[0])) / 57.3;
        return console.log("DEVICE_ORIENTATION-->", id, data);
      });
    };

    return KDisplay;

  })();

  kd = new KDisplay(window.host_url);

  kd.display();

}).call(this);
