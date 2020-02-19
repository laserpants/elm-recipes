'use strict';

var Elm = require('../src/Main.elm').Elm;
var storage = require('./storage.js')('elm-recipes-application-demo-app-session');
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
