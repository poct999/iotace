var bindings = require('bindings')('{{ module_name }}');

{% for f in functions %}
module.exports.{{ f.name }} = bindings.{{ f.name }};
{% endfor %}
