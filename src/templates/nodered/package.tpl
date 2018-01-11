{
    "name": "node-red-{{ module_name }}",
    "version": "0.0.1",
    "description": "IoTace build API",
    "dependencies": {
	"node-red": ">=0.16.2"
    },
    "keywords": [""],
    "node-red": {
        "nodes": {
            {{ nodes }}
        }
    }
}
