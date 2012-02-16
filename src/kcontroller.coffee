#
# Copyright 2012 Kenichi Sato <ksato9700@gmail.com>
#

#
# utilities
#
compare_array = (a,b)->
  if a.length isnt b.length
    return false
  for i in [0...a.length]
    if a[i] isnt b[i]
      return false
  return true

#
# class
#
class KController
  constructor: (host_url)->
    @socket = io.connect host_url

  sense: ->
    @socket.on 'ready', =>
      @display = 0 # tentative
      @socket.emit 'device'
      @sense_location()
      # @sense_battery()

      @orientation = [0, 0, 0]
      @sense_orientation()

  sense_location: ->
    watchId = navigator.geolocation.watchPosition (position)=>
      @socket.emit 'location',
        timestamp: position.timtstamp
        latitude:  position.coords.latitude
        longitude: position.coords.longitude
        altitude:  position.coords.altitude
        accuracy:  position.coords.accuracy
        altitudeAccuracy:  position.coords.altitudeAccuracy
        heading:   position.coords.heading
        speed:     position.coords.speed

    @socket.on 'disconnect', ->
      navigator.geolocation.clearWatch watchId

  sense_battery: ->
    battery = navigator.battery || navigator.mozBattery || navigator.webkitBattery
    @socket.emit 'battery',
      charging:        navigator.battery.charging
      chargingTime:    navigator.battery.chargingTime
      level:           navigator.battery.level
      dischargingTime: navigator.battery.dischargingTime

  sense_orientation: ->
    addEventListener 'deviceorientation', (event)=>
      orientation = (Math.round val for val in [event.alpha, event.beta, event.gamma])
      didnt_change = compare_array orientation, @orientation
      if not didnt_change
        @socket.emit 'deviceorientation', orientation
        @orientation = orientation

kc = new KController window.host_url
kc.sense()