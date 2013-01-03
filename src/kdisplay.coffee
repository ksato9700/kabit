#
# Copyright 2012, 2013 Kenichi Sato <ksato9700@gmail.com>
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

new_color = ->
  Math.random()*0xffffff  

#
# class
#
class KDisplay
  constructor: (host_url)->
    @server = io.connect host_url
    @cubes = []
    @particles = []
    @devices = []

  display: ->
    @server.on 'connected', =>
      @server.emit 'join', {type: 'displays'}

      @display_orientation()
      @display_touch()

      @three_init()
      
      setInterval =>
        @three_render()
      , 32

  three_init: ->
    container = $ '#container'
    @scene = new THREE.Scene()

    # camera
    @camera = new THREE.PerspectiveCamera 70, window.innerWidth/window.innerHeight, 1, 1000
    @camera.position.y = 250
    @camera.position.z = 750

    @lookat = new THREE.Vector3()

    # renderer
    # @renderer = new CanvasRenderer()
    @renderer = new THREE.WebGLRenderer()
    @renderer.setSize window.innerWidth, window.innerHeight
    container.append @renderer.domElement

    # cubes
    @cubes = (@create_cube idx for idx in [0...4])

  three_render: ->
    @renderer.render @scene, @camera
    for cube in @cubes
      cube.rotation.x += 0.01
      cube.rotation.y -= 0.00

    # @lookat.addSelf new THREE.Vector3 0,0,3
    # console.log @lookat
    # @camera.lookAt @lookat

  create_cube: (idx) ->
    #materials = (new THREE.MeshBasicMaterial {color: new_color() } for i in [0...6])
    #material = new THREE.MeshFaceMaterial materials

    material = new THREE.MeshBasicMaterial
      color: new_color()
      opacity: 1.0

    cube_geometory = new THREE.CubeGeometry 240, 20, 320, 1, 1, 1
    cube = new THREE.Mesh cube_geometory, material

    #cube.position.x = -720 + 480*idx
    cube.position.x = 30*idx
    cube.position.y = 30*idx
    cube.rotation.set 1, 0, 0
    @scene.add cube
    return cube

    # particle
    # material = new THREE.ParticleBasicMaterial
    #   map: new THREE.Texture generate_sprite()
    #   blending: THREE.AdditiveBlending

    # particle = new THREE.Particle material
    # particle.scale.multiplyScalar 10
    # particle.visible = false

    # cube.add particle

    # @scene.add particle
    # @particles.push particle

  get_idx: (id)->
    idx = @devices.indexOf id
    if idx < 0
      if @devices.length >= 4
        @devices.shift()
      @devices.push id
      idx = @devices.length-1
    idx

  display_orientation: ->
    @server.on 'deviceorientation', (id, data)=>
      # console.log "DEVICE_ORIENTATION-->", id, data
      idx = @get_idx id
      [ry,rx,rz] = ( val*Math.PI / 180 for val in data)
      rz = - rz
      #console.log idx, rx,ry,rz
      @cube.rotation.set rx, ry, rz
      #@cubes[idx].rotation.set rx, ry, rz
    #@cubes[idx].updateMatrixWorld true

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
    @server.on 'touchstart', (id, data)=>
      @touch_action id, data, true

    @server.on 'touchmove', (id, data)=>
      @touch_action id, data, true

    @server.on 'touchend', (id, data)=>
      @touch_action id, data, false

kd = new KDisplay window.host_url
kd.display()
