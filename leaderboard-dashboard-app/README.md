Leader Board Application 
=======================
**Node** Application that gives Players and Team Leader Board.

Prerequisites
-------------
 - [Node.js 6.0+](http://nodejs.org). For this project, been tested with Node 10.0.0.
 - Install the following modules to successfully build the app-
    - express: used to create, handle routing and process requests from the client.
        - npm install express --save   
    - mysql: Node JS driver for MySQL.
        - npm install mysql --save
    - ejs: templating engine to render html pages for the app.
        - npm install ejs --save
    - nodemon: Installed globally. It is used to watch for changes to files and automatically restart the server.
        - npm install nodemon -g


Run the app
-------------
There are two ways you can use to build this application:
1.  This application gets deployed automatically on running the *../automation.py* as a docker container in the webserver host.
2.  Update the config.json with DB info and run `$nodemon app.js`
