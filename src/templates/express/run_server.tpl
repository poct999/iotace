var api = require('{{ module_name }}_server');


var express  =  require('express');
var app = express();

app.use(express.static(__dirname + '/views'));

api.init_api(app);

var port = 8888;
app.listen( port, function() {
  console.log( `Express server listening on port ${port}` );
});


