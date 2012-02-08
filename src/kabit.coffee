socket = io.connect 'http://localhost:8080'

console.log navigator.battery

socket.on 'ready', ()->
  watchId = navigator.geolocation.watchPosition (position)->
    socket.emit 'location'
      timestamp: position.timtstamp
      latitude:  position.coords.latitude
      longitude: position.coords.longitude
      altitude:  position.coords.altitude
      accuracy:  position.coords.accuracy
      altitudeAccuracy:  position.coords.altitudeAccuracy
      heading:   position.coords.heading
      speed:     position.coords.speed

  socket.on 'disconnect', ->
    navigator.geolocation.clearWatch watchId
