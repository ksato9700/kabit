socket = io.connect 'http://localhost:8080'

socket.on 'ready', ()->
  watchId = navigator.geolocation.watchPosition (position)->
    socket.emit 'location'
      latitude: position.coords.latitude
      longitude: position.coords.longitude

  socket.on 'disconnect', ->
    navigator.geolocation.clearWatch watchId
