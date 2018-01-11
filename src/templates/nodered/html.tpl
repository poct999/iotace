<script type="text/javascript">
    RED.nodes.registerType('{{ function.name }}',{
        category: '{{ module_name }} API',
        color: '#C7E9C0',
        defaults: {
            name: {value:""},
    {% for p in function.in_p %}
            {{ p.name }}: {value:"", required: false {%- if p.final_type==number and not p.array -%}, validate:RED.validators.number(){% endif %}},
    {% endfor %}
        },
        inputs:1,
        outputs:1,
        icon: "iotace.png",
        label: function() {
            return this.name||"{{ function.name }}";
        }
    });
</script>

<script type="text/x-red" data-template-name="{{ function.name }}">

    <div class="form-row">
        <label for="node-input-name"><i class="icon-tag"></i> Name</label>
        <input type="text" id="node-input-name" placeholder="Name">
    </div>
    {% for p in function.in_p %}
    <div class="form-row">
        <label for="node-input-{{ p.name }}"> {{ p.name }}</label>
        <input type="text" value="" id="node-input-{{ p.name }}" placeholder="{{ p.name }}">
    </div>
    {% endfor %}
</script>

<script type="text/x-red" data-help-name="{{ function.name }}">
    <p> Function is called with parameters from <code>msg.payload</code>.
Input parameters must be in JSON format.
If input data is empty, parameters are taken from the node properties</p>
    <h5><b>JS API:</b></h5>
    {% set inputs_js = [] %}
    {% set src_args = [] %}
    {%- for p in function.in_p -%} {%- if inputs_js.append(p.name) -%} {%- endif -%} {% endfor %}
    {%- for p in function.parameters -%} {%- if src_args.append("<span style=\"color: #316EC4\">" + p.type_full + "</span> " + p.name) -%} {%- endif -%} {% endfor %}

    <p><span style="color: #557c21">{{ function.name }}</span><span>({{ inputs_js|join(', ') }})</span></p>
    {% if len(function.out_p) or function.return_final_type != 'void' %}
    <h5><b>Returns:</b></h5>
    <p>Function returns JSON object, which contains following properties:</p>
    <ul>
    {% if function.return_final_type != 'void' %}
    <li><code>{{ function.name }}</code>: {{ function.return_js_info }}</li>
    {% endif %}
    {%- for p in function.out_p -%}
    <li><code>{{ p.name }}</code>: {{ p.js_info }}</li>
    {% endfor %}
    </ul>
    {% endif %}
    <hr>
    <h5><b>Source API:</b></h5>
    <span style="color: #316EC4">{{ function.return_type_full }}</span> <span style="color: #557c21">{{ function.name }}</span><span>({{ src_args|join(', ') }})</span>
    {% if function.html_doxygen %}
    <hr>
    <h5><b>Doxygen:</b></h5>
    <span>{{ function.html_doxygen }}</span>
    {% endif %}
</script>
