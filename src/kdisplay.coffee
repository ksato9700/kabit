#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
#

generate_sprite = ->
  canvas = document.createElement 'canvas'
  canvas.width = 16
  canvas.height = 16
  context = canvas.getContext '2d'

  half_cw = canvas.width/2
  half_ch = canvas.height/2

  gradient = context.createRadialGradient half_cw, half_ch, 0, half_cw, half_ch, half_cw
  gradient.addColorStop 0, 'rgba(255,255,255,1)'
  gradient.addColorStop 0.2, 'rgba(0,255,255,1)'
  gradient.addColorStop 0.4, 'rgba(0,0,64,1)'
  gradient.addColorStop 1, 'rgba(0,0,0,1)'

  context.fillStyle = gradient
  context.fillRect 0, 0, canvas.width, canvas.height
  return canvas



#
# class
#
class KDisplay
  constructor: (host_url)->
    @socket = io.connect host_url
    @cubes = []
    @particles = []
    @devices = []

  display: ->
    @socket.on 'ready', =>
      @socket.emit 'display'
      @display_orientation()
      @display_touch()

      @three_init()
      timer = setInterval =>
        @three_render()
      , 16

      @socket.on 'id', (id)=>
        @id = id

  three_init: ->
    container = $ '#container'
    @scene = new THREE.Scene()

    # camera
    @camera = new THREE.PerspectiveCamera 90, window.innerWidth / window.innerHeight, 120, 10000
    @camera.position.y = 250
    @camera.position.z = 750
    @scene.add @camera

    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize window.innerWidth, window.innerHeight
    container.append @renderer.domElement

    @create_cubes idx for idx in [0...4]

  create_cubes: (idx) ->
    # cube
    materials = (new THREE.MeshBasicMaterial { color: Math.random() * 0xffffff } for i in [0...6])

    position_x = -720 + 480*idx

    cube_geometory = new THREE.CubeGeometry 240, 20, 320, 1, 1, 1, materials
    cube_face = new THREE.MeshFaceMaterial()
    cube = new THREE.Mesh cube_geometory, cube_face
    cube.position.x = position_x
    cube.position.y = 150
    cube.rotation.set 1, 0, 0
    cube.overdraw = true
    @scene.add cube
    @cubes.push cube

    # particle
    material = new THREE.ParticleBasicMaterial
      map: new THREE.Texture generate_sprite()
      blending: THREE.AdditiveBlending

    particle = new THREE.Particle material
    particle.scale.multiplyScalar 10
    particle.visible = false

    cube.add particle

    # @scene.add particle
    @particles.push particle

  three_render: ->
    @renderer.render @scene, @camera

  get_idx: (id)->
    idx = @devices.indexOf id
    if idx < 0
      if @devices.length >= 4
        @devices.shift()
      @devices.push id
      idx = @devices.length-1
    idx

  display_orientation: ->
    @socket.on 'deviceorientation', (id, data)=>
      idx = @get_idx id
      rx = (parseInt data[1])/57.3
      ry = (parseInt data[0])/57.3
      rz = -(parseInt data[2])/57.3
      @cubes[idx].rotation.set rx, ry, rz
      @cubes[idx].updateMatrixWorld true

      # console.log "DEVICE_ORIENTATION-->", id, data

  touch_action: (id, data, visible)->
      idx = @get_idx id
      if visible
        x = 240* data[0] - 120
        y = 320* data[1] - 160
        @particles[idx].visible = true
        @particles[idx].position.set x, 80, y
        # console.log "TOUCH POSITION-->", id, x, y
      else
        @particles[idx].visible = false


  display_touch: (idx)->
    @socket.on 'touchstart', (id, data)=>
      @touch_action id, data, true

    @socket.on 'touchmove', (id, data)=>
      @touch_action id, data, true

    @socket.on 'touchend', (id, data)=>
      @touch_action id, data, false

kd = new KDisplay window.host_url
kd.display()
