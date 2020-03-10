'use strict';

require('../index.html');

var Elm = require('../src/Main.elm').Elm;
var states = require('./data');

var app = Elm.Main.init({
  node: document.getElementById('elm-code'),
  flags: {}
});

if (app.ports && app.ports.websocketOut && app.ports.websocketIn) {
  app.ports.websocketOut.subscribe(function(data) {
    var envelope = JSON.parse(data),
        message = envelope.payload;
    if ('search' === envelope.type) {
      setTimeout(function() {
        var suggestions = (states.get(message.query) || []).map(([score, value]) => value);
        var response = {
          type: 'suggestions',
          payload: { query: message.query, suggestions }
        };
        app.ports.websocketIn.send(JSON.stringify(response));
      }, 350);
    }
  });
}
