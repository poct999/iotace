{
  "dependencies": {
    "bindings": "^1.2.1"
  },
  "directories": {},
  "engines": {
    "node": ">= 0.6.0"
  },
  "main": "./{{ module_name }}.js",
  "name": "{{ module_name }}",
  "optionalDependencies": {},
  "readme": "ERROR: No README data found!",
  "scripts": {
    "install": "node-gyp rebuild",
    "test": "node-gyp configure build"
  },
  "author": "",
  "license": "MIT",
  "description": "",
  "version": "1.0.0"
}
