#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
#

#
# class
#
class KDisplay
  constructor: (host_url)->
    @socket = io.connect host_url

  display: ->
    @socket.on 'ready', =>
      @socket.emit 'display'
      @display_orientation()

      @three_init()
      timer = setInterval =>
        @three_render()
      , 16

  three_init: ->
    container = $ '#container'
    @scene = new THREE.Scene()

    # camera
    @camera = new THREE.PerspectiveCamera 70, window.innerWidth / window.innerHeight, 1, 1000
    @camera.position.y = 150
    @camera.position.z = 500
    @scene.add @camera

    # cube
    materials = (new THREE.MeshBasicMaterial { color: Math.random() * 0xffffff } for i in [0...6])

    cube_geometory = new THREE.CubeGeometry 100, 20, 200, 1, 1, 1, materials
    cube_face = new THREE.MeshFaceMaterial()
    @cube = new THREE.Mesh cube_geometory, cube_face
    @cube.position.y = 150
    @cube.overdraw = true
    @scene.add @cube

    # plane
    plane_geometry = new THREE.PlaneGeometry 100, 200
    plane_material = new THREE.MeshBasicMaterial { color: 0xe0e0e0 }
    @plane = new THREE.Mesh plane_geometry, plane_material
    @plane.rotation.x = - 90 * ( Math.PI / 180 )
    @plane.overdraw = true
    @scene.add @plane

    @renderer = new THREE.CanvasRenderer()
    @renderer.setSize window.innerWidth, window.innerHeight
    container.append @renderer.domElement

  three_render: ->
    @renderer.render @scene, @camera

  display_orientation: ->
    @socket.on 'deviceorientation', (data)=>
      @cube.rotation.x = (parseInt data[1])/57.3
      @cube.rotation.y = (parseInt data[0])/57.3
      @cube.rotation.z = -(parseInt data[2])/57.3
      @plane.rotation.x = (parseInt data[1])/57.3 - 90 * ( Math.PI / 180 )
      @plane.rotation.y = (parseInt data[2])/57.3
      @plane.rotation.z = (parseInt data[0])/57.3
      console.log "DEVICE_ORIENTATION-->", data

kd = new KDisplay window.host_url
kd.display()
