var hubotify;

hubotify = {
  init: function() {
    var models, player, socket, sp;
    socket = io.connect('http://local.aries.dev:8080');
    sp = getSpotifyApi();
    models = sp.require('$api/models');
    player = models.player;
    document.getElementById('btn-submit').addEventListener('click', function(e) {
      e.preventDefault();
      return socket.emit('join', document.getElementById('room').value);
    });
    player.observe(models.EVENT.CHANGE, function(evt) {
      return socket.emit('trackchnge', player.track);
    });
    return socket.on('welcome', function(data) {
      return hubotify.trackEvent("Connected to Hubot (" + data.name + ")");
    });
  },
  trackEvent: function(evt, user) {
    var evtItem;
    evtItem = document.createElement('li');
    evtItem.innerHTML = evt;
    if (user) {
      evtItem.innerHTML += " by " + user;
    }
    return document.querySelector('#content > ul').appendChild(evtItem);
  }
};

window.onload = hubotify.init;