hubotify =
  socket: null
  init: () ->
    socket = io.connect 'http://local.aries.dev:8080'

    sp = getSpotifyApi()
    models = sp.require('$api/models')
    player = models.player

    document.getElementById('btn-submit').addEventListener 'click', (e) ->
      e.preventDefault()
      socket.emit 'join', document.getElementById('room').value

    player.observe models.EVENT.CHANGE, (evt) ->
      socket.emit 'trackchnge', player.track

    socket.on 'welcome', (data) ->
      hubotify.trackEvent "Connected to Hubot #{data.name}"

    trackEvent: (evt, user) ->
    evtItem = document.createElement 'li';
    evtItem.innerHTML = evt;

    if user
      evtItem.innerHTML += " by #{user}"

    document.querySelector('#content > ul').appendChild evtItem

window.onload = hubotify.init
