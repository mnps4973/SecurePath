const fs = require('fs');
const express = require('express');
const app = express();
const axios = require('axios');
const ejs = require('ejs');
const bodyParser = require('body-parser');



// Serve static files from the public directory
app.use(express.static('public'))
app.use(bodyParser.urlencoded({ extended: false }))

// parse application/json
app.use(bodyParser.json())
console.log("Added assets folder to static files system.")

app.set('view engine', 'ejs');
app.set('views', './');

const logRequests = (req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} - ${req.originalUrl}`);
  next();
};

app.use(logRequests);
//app.use(validateSession);

app.get('/', (req, res) => {
  fs.readFile('index.html', (err, data) => {
    if (err) {
      res.writeHead(500);
      res.end('Error loading index.html');
      console.error(err);
    } else {
      res.writeHead(200, { 'Content-Type': 'text/html' });
      res.end(data);
    }
  });
});


app.get('/api/*', async (req, res) => {
  try {
    const pathSegments = req.params;
    const value = pathSegments[0];
      const response = await axios.get('http://localhost:8000/' + value);
      const data = response.data;
      res.send(data);
  } catch (error) {
      console.error(error);
      res.status(500).send('Server Error');
  }
});

app.post('/api/*', async (req, res) => {
  try {
    const pathSegments = req.params;
    const value = pathSegments[0];
    const response = await axios.post('http://localhost:8000/' + value, req.body);
    const data = response.data;
    res.send(data);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server Error');
  }
});

app.put('/api/*', async (req, res) => {
  try {
    const pathSegments = req.params;
    const value = pathSegments[0];
    const response = await axios.put('http://localhost:8000/' + value, req.body);
    const data = response.data;
    res.send(data);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server Error');
  }
});

app.delete('/api/*', async (req, res) => {
  try {
    const pathSegments = req.params;
    const value = pathSegments[0];
    const response = await axios.delete('http://localhost:8000/' + value, req.body);
    const data = response.data;
    res.send(data);
  } catch (error) {
    console.error(error);
    res.status(500).send('Server Error');
  }
});

app.get('/dashboard', (req, res) => {
  res.render('dashboard.ejs');
});

app.get('/faqs', async (req, res) => {
  try {
    const response = await axios.get('http://localhost:3000/api/faq/');
    const data = response.data;
    res.render('faqs.ejs', { data });
  } catch (error) {
    console.error(error);
  }
});

app.get('/faq', (req, res) => {
  // code to render a blank form for creating a new user
  res.render('faqdetail.ejs', { faq: {} });
});

app.get('/faq/:id', async (req, res) => {
  try {
    const faqid = req.params.id;
  if (faqid) {
    const response = await axios.get('http://localhost:3000/api/faq/' + faqid);
      const faq = response.data;
      res.render('faqdetail.ejs', { faq, faqid });
  } else {
  }
  } catch (error) {
    console.error(error);
  }
  
});

app.get('/faqview/:id', async (req, res) => {
  try {
    const faqid = req.params.id;
  if (faqid) {
    const response = await axios.get('http://localhost:3000/api/faq/' + faqid);
      const faq = response.data;
      res.render('faqdetailview.ejs', { faq, faqid });
  } else {
  }
  } catch (error) {
    console.error(error);
  }
  
});

app.get('/users', async (req, res) => {
  try {
    const response = await axios.get('http://localhost:3000/api/user');
    const data = response.data;
    res.render('users.ejs', { data });
  } catch (error) {
    console.error(error);
  }
});

app.get('/user', (req, res) => {
  // code to render a blank form for creating a new user
  res.render('userdetail.ejs', { user: {} });
});

app.get('/user/:id', async (req, res) => {
  try {
    const userId = req.params.id;
  if (userId) {
    const response = await axios.get('http://localhost:3000/api/user/' + userId);
      const user = response.data;
      res.render('userdetail.ejs', { user });
  } else {
  }
  } catch (error) {
    console.error(error);
  }
  
});

app.post('/user', (req, res) => {
  const userData = req.body;
  console.log(req.body);

  if(userData.password === userData.password_confirm)
  {
    axios.post('http://localhost:3000/api/user/', userData)
    .then(response => {
      console.log(response.data);
      res.send('User created successfully!');
    })
    .catch(error => {
      console.error(error);
      res.send('Error creating user.');
    });
  }
  else
  {
    res.send('Passwords must be the same.');
  }
  
});

function validateSession(req, res, next) {

  if(!req.cookies)
  if (!req.cookies.username || !req.cookies.sessionToken) {
    res.redirect('/');
  }

  const username = req.cookies.username;
  const sessionToken = req.cookies.sessionToken;

  axios.post('http://localhost:8000/validate_session', {
    username: username,
    session_token: sessionToken
  })
  .then(response => {
    console.log(response);
    if (response.status === 200) {
      const data = response.data;
      document.cookie = `username=${data.username}; expires=${data.validuntil}; session_token=${data.session_token}`;
      next();
    } else {
      res.redirect('/');
    }
  })
  .catch(error => {
    console.error(error);
    res.redirect('/');
  });
}

app.listen(3000, () => {
  console.log('Server started on http://localhost:3000');
});