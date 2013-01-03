#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
#

#
# utilities
#
compare_orientation = (a,b)->
  return a[0] is b[0] and a[1] is b[1] and a[2] is b[2]

round_and_pack_orientation = (event, th)->
  new Int16Array((((Math.round val/th)*th) for val in [event.alpha, event.beta, event.gamma]))

#
# class
#
class KController
  constructor: (host_url)->
    console.log host_url
    @server = io.connect host_url

  sense: ->
    @server.on 'connected', =>
      console.log 'connected'
      @server.emit 'join', {type: 'controllers'}
      # @sense_location()
      # @sense_battery()

      @sense_touch()

      @orientation = [0, 0, 0]
      @calibration()
      @sense_orientation()

      @height = window.innerHeight
      @width  = window.innerWidth

  sense_location: ->
    watchId = navigator.geolocation.watchPosition (position)=>
      @server.emit 'location',
        timestamp: position.timtstamp
        latitude:  position.coords.latitude
        longitude: position.coords.longitude
        altitude:  position.coords.altitude
        accuracy:  position.coords.accuracy
        altitudeAccuracy:  position.coords.altitudeAccuracy
        heading:   position.coords.heading
        speed:     position.coords.speed

    @server.on 'disconnect', ->
      navigator.geolocation.clearWatch watchId

  sense_battery: ->
    battery = navigator.battery || navigator.mozBattery || navigator.webkitBattery
    @server.emit 'battery',
      charging:        navigator.battery.charging
      chargingTime:    navigator.battery.chargingTime
      level:           navigator.battery.level
      dischargingTime: navigator.battery.dischargingTime

  send_touch: (type, event)->
    touch = event.touches[0] # use only the first data
    if touch
      data = [touch.screenX/@width, touch.screenY/@height]
    else
      data = null
    @server.emit type, data
    event.preventDefault()

  sense_touch: ->
    addEventListener 'touchstart', (event)=>
      @send_touch 'touchstart', event

    addEventListener 'touchmove', (event)=>
      @send_touch 'touchmove', event

    addEventListener 'touchend', (event)=>
      @send_touch 'touchend', event

  sense_orientation: ->
    addEventListener 'deviceorientation', (event)=>
      orientation = round_and_pack_orientation(event, 3)
      didnt_change = compare_orientation orientation, @orientation
      if not didnt_change
        #console.log orientation
        @server.emit 'deviceorientation', orientation
        @orientation = orientation

  calibration: ->
    addEventListener 'compassneedscalibration', (event)->
          console.log 'Your compass needs calibrating! Wave your device in a figure-eight motion'
          event.preventDefault()
      , true


kc = new KController window.host_url
console.log kc
kc.sense()