const SerialPort = require('serialport');
const parsers = SerialPort.parsers;

var cb = null;

const port = new SerialPort('/dev/ttyACM0', {
	baudRate: 115200,
	parser: SerialPort.parsers.readline('\n')
});

port.on('data', function(data){
    if (cb) 
    	cb(data);
});

function work(dt, callback) {	
    port.write(dt, function(){
        cb = callback;
    });
}

port.on('error', function(err) {
    console.log('SerialPort error: ', err.message);
});

function uart_call(name, arguments, callback) {
    args = [];
    
    for (var i = 0; i < arguments.length; i++) {
        if (typeof arguments[i] === 'string' || arguments[i] instanceof String)
            args.push("'"+arguments[i]+"'");
        else 
            args.push(JSON.stringify(arguments[i]));
    }
    
    func = "JSON.stringify(" + name + "("+args.join()+'));\r\n';
    
    work(func, callback);
}

{% for f in functions %}
module.exports.{{ f.name }} = function(arguments = [], callback = null) {
    uart_call("{{ f.name }}", arguments, callback);
};
{% endfor %}


