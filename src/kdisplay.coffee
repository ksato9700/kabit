#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
#

#
# class
#
class KDisplay
  constructor: (host_url)->
    @socket = io.connect host_url
    @cubes = []
    @planes = []
    @devices = []

  display: ->
    @socket.on 'ready', =>
      @socket.emit 'display'
      @display_orientation()

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
    @camera = new THREE.PerspectiveCamera 70, window.innerWidth / window.innerHeight, 100, 1000
    @camera.position.y = 150
    @camera.position.z = 500
    @scene.add @camera

    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize window.innerWidth, window.innerHeight
    container.append @renderer.domElement

    @create_cube_plane idx for idx in [0...4]

  create_cube_plane: (idx) ->
    # cube
    materials = (new THREE.MeshBasicMaterial { color: Math.random() * 0xffffff } for i in [0...6])

    position_x = -300+ 200*idx

    cube_geometory = new THREE.CubeGeometry 100, 20, 200, 1, 1, 1, materials
    cube_face = new THREE.MeshFaceMaterial()
    cube = new THREE.Mesh cube_geometory, cube_face
    cube.position.x = position_x
    cube.position.y = 150
    cube.overdraw = true
    @scene.add cube
    @cubes.push cube

    # plane
    plane_geometry = new THREE.PlaneGeometry 100, 200
    plane_material = new THREE.MeshBasicMaterial { color: 0xe0e0e0 }
    plane = new THREE.Mesh plane_geometry, plane_material
    plane.position.x = position_x
    plane.rotation.x = - 90 * ( Math.PI / 180 )
    plane.overdraw = true
    @scene.add plane
    @planes.push plane

  three_render: ->
    @renderer.render @scene, @camera

  display_orientation: ->
    @socket.on 'deviceorientation', (id, data)=>
      idx = @devices.indexOf(id)
      if idx < 0
        if @devices.length >= 4
          @devices.shift()
        @devices.push id
        idx = @devices.length-1

      @cubes[idx].rotation.x = (parseInt data[1])/57.3
      @cubes[idx].rotation.y = (parseInt data[0])/57.3
      @cubes[idx].rotation.z = -(parseInt data[2])/57.3
      @planes[idx].rotation.x = (parseInt data[1])/57.3 - 90 * ( Math.PI / 180 )
      @planes[idx].rotation.y = (parseInt data[2])/57.3
      @planes[idx].rotation.z = (parseInt data[0])/57.3
      console.log "DEVICE_ORIENTATION-->", id, data

kd = new KDisplay window.host_url
kd.display()
