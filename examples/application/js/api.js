'use strict';

var xhook = require('xhook');
var { users, posts } = require('./data.js');

var delay = 400;

xhook.before(function(request, callback) {
  setTimeout(function() { 
    if (request.url.endsWith('auth/login') && 'POST' === request.method) {
      var params = JSON.parse(request.body),
          filtered = users.filter(function(user) {
        return user.email === params.email && user.password === params.password;
      });
      if (filtered.length > 0) {
        var user = filtered[0];
        user.rememberMe = params.rememberMe;
        var response = { session: { user: user } };
        callback({
          status: 200,
          data: JSON.stringify(response),
          headers: { 'Content-Type': 'application/json' }
        });
      } else {
        // 401 Unauthorized
        callback({
          status: 401,
          data: JSON.stringify({ error: 'Unauthorized' }),
          headers: { 'Content-Type': 'application/json' }
        });
      }
    } else if (request.url.endsWith('posts')) {
      if ('GET' === request.method) {
        var response = posts.slice().reverse(); 
        console.log(response);
        callback({
          status: 200,
          data: JSON.stringify({ posts: response }),
          headers: { 'Content-Type': 'application/json' }
        });
      } else if ('POST' === request.method) {
        var post = JSON.parse(request.body);
        post.id = posts.length + 1;
        post.comments = [];
        posts.push(post);
        callback({
          status: 200,
          data: JSON.stringify({ post: post }),
          headers: { 'Content-Type': 'application/json' }
        });
      }
    }
  }, delay);
});
