hubotify =
  socket: null
  playlist: null

  # Setup the hubotify application
  init: () ->
    socket = io.connect 'http://localhost:8081'

    sp = getSpotifyApi()
    models = sp.require('$api/models')
    player = models.player

    document.getElementById('btn-update-settings').addEventListener 'click', (e) ->
      e.preventDefault()

      room = document.getElementById('room').value
      playlisturi = document.getElementById('playlisturi').value

      if room
        socket.emit 'join', document.getElementById('room').value
        hubotify.activity "Now broadcasting to room '#{room}'"
      if playlisturi
        hubotify.playlist = models.Playlist.fromURI(playlisturi)
        hubotify.activity "Now managing playlist '#{playlisturi}'"

    player.observe models.EVENT.CHANGE, (evt) ->
      socket.emit 'trackchnge', player.track

    socket.on 'connection', (socket) ->
      hubotify.activity "Connection to Hubot established successfully"
      socket.on 'disconnect', ->
        hubotify.activity "Connection to Hubot lost"

    socket.on 'welcome', (data) ->
      hubotify.activity "Connected to Hubot: #{data.name}"

    socket.on 'trackdrop', (track) ->
      if hubotify.playlist
        console.log track
        hubotify.playlist.remove track.uri
        hubotify.activity "Removed track '#{track.name}' from '#{track.artists[0].name}' from playlist"
      else
        hubotify.activity "Track removal request received, but no playlist being managed!", 1

    socket.on 'play:next', ->
      player.next()

  # Log an activity event
  activity: (evt, level = 0) ->
    evtItem = document.createElement 'li';
    evtItem.innerHTML = evt;

    if level is 1
      evtItem.setAttribute 'style', 'color:#cc0000;';
    if level is 2
      evtItem.setAttribute 'style', 'color:#ff0000;';

    document.querySelector('#activity > ul').appendChild evtItem

window.onload = hubotify.init
