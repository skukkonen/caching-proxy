var express         = require('express');
var morgan          = require('morgan');
var cookieParser    = require('cookie-parser');
var bodyParser      = require('body-parser');
var connect         = require('connect');
var connectTimeout  = require('connect-timeout');
var log             = require('simplog');


var app = express();

app.use(connect());
app.use(morgan('combined'));
app.use(cookieParser());
// parse application/x-www-form-urlencoded
//app.use(bodyParser.urlencoded({ extended: false }))
// parse application/json
app.use(bodyParser.raw({type: "application/*"}));
app.use("/", express.static(__dirname + "/site"));
// parse application/vnd.api+json as json
app.use(bodyParser.json({ type: 'application/vnd.api+json' }))


app.all("/echo/*", function (request, response) {
  respondWithThis = {
    body: request.body.toString(),
    queryString: request.query
  };
  response.send(JSON.stringify(respondWithThis, null, 2));
});


listenPort = process.env.PORT || 3000;
log.info("starting app " + process.env.APP_NAME);
log.info("listening on " + listenPort);
app.listen(listenPort);
