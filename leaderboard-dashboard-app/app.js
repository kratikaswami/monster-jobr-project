const express = require('express');
const mysql = require('mysql');
const app = express();

const {getHomePage} = require('./routes/index');
const port = '8080';
const fs = require('fs');

// create connection to database
var parsed = JSON.parse(fs.readFileSync("./config.json", 'UTF-8'))
var db  = mysql.createConnection({
        host    : parsed.host,
        user    : parsed.user,
        password: parsed.password,
        database: parsed.database
})

// connect to database
db.connect((err) => {
    if (err) {
        throw err;
    }
    console.log('Connected to database');
});
global.db = db;

// configure middleware
app.set('port', process.env.port || port); // set express to use this port
app.set('views', __dirname + '/views'); // set express to look in this folder to render our view
app.set('view engine', 'ejs'); // configure template engine

// routes for the app
app.get('/', getHomePage);

// set the app to listen on the port
app.listen(port, () => {
    console.log(`Server running on port: ${port}`);
});
