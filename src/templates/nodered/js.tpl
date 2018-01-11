api = require('{{ module_name }}');
module.exports = function(RED) {
    function Node_{{ function.name }}(config) {
        RED.nodes.createNode(this,config);
        var node = this;

        this.on('input', function(msg) {
            {% for p in function.in_p %}
                {%- if p.final_type != "string" -%}
            node.{{ p.name }} =  config.{{ p.name }} ? JSON.parse(config.{{ p.name }}) : msg.payload.{{ p.name }};
                {%- else -%}
            node.{{ p.name }} =  config.{{ p.name }} ? config.{{ p.name }} : msg.payload.{{ p.name }};
                {% endif %}
            {% endfor %}
            {%- set args = [] -%}
            {%- for p in function.in_p -%}
                {%- if args.append("node." + p.name + "") -%} {%- endif -%}
            {% endfor %}

            msg.payload = api.{{ function.name }}({{ args|join(', ') }});

            node.send(msg);
            return 0;
        });
    }
    RED.nodes.registerType("{{ function.name }}", Node_{{ function.name }});
}
