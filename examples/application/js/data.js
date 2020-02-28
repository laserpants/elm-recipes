var users = 
[
  {
    id: 1,
    name: 'Winston Smith',
    password: 'test',
    email: 'test@test.com',
    rememberMe: false
  }
];

var posts =
[
  {
    id: 1,
    title: 'What is the facepalm?',
    body: 'A facepalm is the physical gesture of placing one’s hand across one’s face or lowering one’s face into one’s hand or hands, covering or closing one’s eyes.',
    comments: 
    [{
       id: 1,
       postId: 1,
       email: 'facepalm@test.com',
       body: 'Thanks for this information. I would just like to mention here the double facepalm, which is similar to the facepalm but performed with two hands. Keep up the good work!'
     },
     {
       id: 2,
       postId: 1,
       email: 'info@spam.org',
       body: 'Buy potatoes online. Delivery next day.'
    }]
  },
  {
    id: 2,
    title: 'Online use of the facepalm',
    body: 'Use of the gesture is not limited to visual representations. Often just the word, facepalm, is used to show someone’s disapproval or embarrassment.',
    comments: []
  }
];

module.exports = { users, posts };
