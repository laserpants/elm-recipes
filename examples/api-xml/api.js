var xhook = require('xhook');

var books = require('./books.xml');
var delay = 450;

xhook.before(function(request, callback) {
  if (/books\/\d+$/.test(request.url) && 'GET' === request.method) {
    setTimeout(function() {
      var id = request.url.match(/books\/(\d+)$/)[1],
          filtered = books.collection.book.filter(function(book) { return book.id == id; });
      if (filtered.length > 0) {
        var book = filtered[0];
        var bookXml = `<body><book><id>${book.id}</id><title>${book.title}</title><author>${book.author}</author><synopsis>${book.synopsis}</synopsis></book></body>`;
        callback({
          status: 200,
          data: bookXml,
          headers: { 'Content-Type': 'application/xml' }
        });
      } else {
        console.log('Not Found');
        callback({
          status: 404,
          data: '<error>Not Found</error>',
          headers: { 'Content-Type': 'application/xml' }
        });
      }
    }, delay);
  } else {
    callback();
  }
});
