var xhook = require('xhook');

var books =
  [
    {
      id: 1,
      title: 'Moby Dick',
      author: 'Herman Melville',
      synopsis: 'Sailor Ishmael\'s narrative of the obsessive quest of Ahab, captain of the whaling ship Pequod, for revenge on Moby Dick, the giant white sperm whale that on the ship\'s previous voyage bit off Ahab\'s leg at the knee.'
    },
    {
      id: 2,
      title: 'War and Peace ',
      author: 'Leo Tolstoy',
      synopsis: 'The novel chronicles the French invasion of Russia and the impact of the Napoleonic era on Tsarist society through the stories of five Russian aristocratic families.'
    },
    {
      id: 3,
      title: 'The Three Musketeers',
      author: 'Alexandre Dumas',
      synopsis: 'Situated between 1625 and 1628, it recounts the adventures of a young man named d\'Artagnan (based on Charles de Batz-Castelmore d\'Artagnan) after he leaves home to travel to Paris, to join the Musketeers of the Guard.'
    },
    {
      id: 4,
      title: 'Ulysses',
      author: 'James Joyce',
      synopsis: 'Ulysses chronicles the peripatetic appointments and encounters of Leopold Bloom in Dublin in the course of an ordinary day, 16 June 1904.'
    },
    {
      id: 5,
      title: 'Frankenstein',
      author: 'Mary Shelley',
      synopsis: 'The story of Victor Frankenstein, a young scientist who creates a hideous sapient creature in an unorthodox scientific experiment.'
    }
  ];

var delay = 450;

xhook.before(function(request, callback) {
  if (/books\/\d+$/.test(request.url) && 'GET' === request.method) {
    setTimeout(function() {
      var id = request.url.match(/books\/(\d+)$/)[1],
          filtered = books.filter(function(book) { return book.id == id; });
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
