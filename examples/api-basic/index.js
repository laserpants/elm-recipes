'use strict';

require('./index.html');
require('./api.js');

var Elm = require('./src/Main.elm').Elm;

var app = Elm.Main.init({
  node: document.getElementById('elm-code'),
  flags: {}
});
