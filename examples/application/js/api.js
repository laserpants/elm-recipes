'use strict';

var xhook = require('xhook');
var { users, posts, comments } = require('./data.js');

var delay = 400;

xhook.before(function(request, callback) {
  setTimeout(function() { 
    if (request.url.endsWith('auth/register') && 'POST' === request.method) {
      var params = JSON.parse(request.body);
      params.id = users.length + 1;
      users.push(params);
      var user = {
        id: params.id,
        name: params.name,
        username: params.username,
        email: params.email,
        phoneNumber: params.phoneNumber,
        rememberMe: false
      };
      callback({
        status: 200,
        data: JSON.stringify({ status: 'success', user: user }),
        headers: { 'Content-Type': 'application/json' }
      });
    } else if (request.url.endsWith('auth/login') && 'POST' === request.method) {
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
    } else if (/posts\/\d+$/.test(request.url) && 'GET' === request.method) {
      var id = request.url.match(/posts\/(\d+)$/)[1],
          filtered = posts.filter(function(post) { return post.id == id; });
      if (filtered.length > 0) {
        var response = filtered[0];
        callback({
          status: 200,
          data: JSON.stringify({ post: response }),
          headers: { 'Content-Type': 'application/json' }
        });
      } else {
        console.log('Not Found');
        callback({
          status: 404,
          data: JSON.stringify({ error: 'Not Found' }),
          headers: { 'Content-Type': 'application/json' }
        });
      }
    } else if (/posts\/\d+\/comments$/.test(request.url) && 'POST' === request.method) {
      var comment = JSON.parse(request.body),
          postId = request.url.match(/posts\/(\d+)\/comments$/)[1],
          filtered = posts.filter(function(post) { return post.id == postId; });
      if (filtered.length > 0) {
        var post = filtered[0];
        post.comments = post.comments || [];
        comment.id = comments.lenght + 1;
        comments.push(comment);
        post.comments.unshift(comment);
        callback({
          status: 200,
          data: JSON.stringify({ post: post, comment: comment }),
          headers: { 'Content-Type': 'application/json' }
        });
      } else {
        console.log('Not Found');
        callback({
          status: 404,
          data: JSON.stringify({ error: 'Not Found' }),
          headers: { 'Content-Type': 'application/json' }
        });
      }
    } else {
      callback();
    }
  }, delay);
});
