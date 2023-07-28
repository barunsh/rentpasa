const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./routers/user.route');
const propertyRouter = require('./routers/property.route');
const bookRouter = require('./routers/book.route');
const cors = require('cors');

const app = express();

// Enable CORS to allow requests from any origin. Replace '*' with your frontend URL if needed.
app.use(cors({
  origin: '*'
}));

app.use(bodyParser.urlencoded({ extended: true }));
app.use(bodyParser.json({ limit: '50mb' }));

app.use('/user', userRouter);
app.use('/property', propertyRouter);
app.use('/book', bookRouter);

module.exports = app;
