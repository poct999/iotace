var nodejs_module = require('{{ module_name }}');

var bodyParser = require('body-parser');
var swig = require('swig');

function api_v1(req) {
    var ret = {};

    var data = req.body;

    var method = data.method;
    var params = data.params;
    var jsonrpc = data.jsonrpc;
    var id = Number(data.id);

    if ((jsonrpc != "2.0") || method.length == 0 || id.length == 0) {
        ret = JSON.stringify({"jsonrpc":"2.0", "error":{"code": -32700, "message": "Parse error"},"id": null});
        return ret;
    }

    var result = {};
    try {
        var args = JSON.parse(params);

        var call_func = eval("nodejs_module."+method);
        call_args = [];

        var call_args = [];
        if (Array.isArray(args))
            call_args = args;
        {% for f in functions %}
        else if (method == "{{ f.name }}")
             call_args = [{%- for p in f.in_p -%}args.{{ p.name }},{%- endfor -%}];
        {% endfor %}
        else
            call_args = [];


        result = call_func.apply(this, call_args);

    } catch (err) {
        ret = JSON.stringify({"jsonrpc":"2.0", "error":{"code": -32600, "message": err}, "id": null});
        return ret;
    }


    ret = JSON.stringify({"jsonrpc": "2.0", "result": result, "id": id});
    return ret;
}


function home(req, res, next) {
    ret = api_v1(req);

    var rend = {"data":ret, "req":req};
    if (JSON.parse(ret).error)
        rend["error"] = 1;
    else
        rend["error"] = 0;

    return res.render( 'main.html', rend );
}

function init_api(app) {
    app.engine('html', swig.renderFile);
    app.set('view engine', 'html');

    app.set('views', __dirname + '/views');

    app.use(bodyParser.urlencoded({ extended: false }));
    app.use(bodyParser.json());

    app.set('view engine', 'swig');

    app.post( '/', home);
    app.get( '/', home);

    app.post( '/api/v1', function( req, res, next ) {
        return res.status( 200 ).send( api_v1(req) );
    });
}


module.exports.init_api = init_api;
