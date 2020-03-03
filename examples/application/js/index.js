'use strict';

var Elm = require('../src/Main.elm').Elm;
var storage = require('./storage.js')('elm-recipes-application-demo-app-session');

require('./api.js');
require('../index.html');

var app = Elm.Main.init({
  node: document.getElementById('elm-code'),
  flags: {
    session: storage.getItem(),
    basePath: ''
  }
});

storage.initSessionStorage(app, function(data) {
  return data.user.rememberMe;
});

var usernamesTaken = ['bob', 'laserpants', 'neo', 'neonpants', 'admin', 'speedo'];

if (app.ports && app.ports.websocketOut && app.ports.websocketIn) {
  app.ports.websocketOut.subscribe(function(data) {
    var envelope = JSON.parse(data),
        message = envelope.payload;
    if ('username_available_query' === envelope.type) {
      setTimeout(function() {
        var response = {
          type: 'username_available_response',
          payload: {
            username: message.username,
            is_available: (-1 === usernamesTaken.indexOf(message.username))
          }
        };
        app.ports.websocketIn.send(JSON.stringify(response));
      }, 200);
    }
  });
}
