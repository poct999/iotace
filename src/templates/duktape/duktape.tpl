#include "duktape.h"
#include "{{header_name}}"

{% for f in functions %}
duk_ret_t iotace_f_{{ f.name }}(duk_context * ctx)
{
    {% for p in f.parameters %}
        {%- if p.final_type == "string" -%}
    char* iotace_{{ p.name }};
        {%- elif not p.array -%}
    {{ p.type }} iotace_{{ p.name }};
        {% endif %}
    {% endfor %}

    {%- if f.array_in_flag -%}
    duk_size_t i;
    duk_size_t n;
    {% endif %}

    {%- for i,p in enumerate(f.in_p) -%}
        {%- if p.final_type == "string" -%}
    iotace_{{ p.name }} = (char*) duk_to_string(ctx, {{ i }});
        {%- elif not p.array -%}
    iotace_{{ p.name }} = duk_to_number(ctx, {{ i }});
        {% endif %}
    {% endfor %}

    {%- for p in f.parameters -%}
        {%- if p.array -%}
            {%- if p.final_type == "string" -%}
    {{ p.type_full }} tmp_iotace_{{ p.name }} = ({{ p.type_full }}) calloc({{ p.array_count }}, sizeof({{ p.element_type }}));
                {%- if p.route == "in/out" -%}
    strcpy(tmp_iotace_{{ p.name }}, iotace_{{ p.name }});
                {% endif %}
    iotace_{{ p.name }} = tmp_iotace_{{ p.name }};
            {% else %}
    {{ p.type_full }} iotace_{{ p.name }} = ({{ p.type_full }}) calloc({{ p.array_count }}, sizeof({{ p.element_type }}));
            {% endif %}{% endif %}{% endfor %}

    {%- for i, p in enumerate(f.in_p) -%}
        {% if p.array and p.final_type != "string" %}
    n = duk_get_length(ctx, {{ i }});
    for (i = 0; i < n; i++) {
        duk_get_prop_index(ctx, 0, i);
        iotace_{{ p.name }}[i] = duk_to_number(ctx, -1);
        duk_pop(ctx);
    }
    {% endif %}
    {%- endfor -%}
    {%- if len(f.out_p) or f.return_basic_type_full != 'void' -%}
    duk_idx_t obj_idx;
    obj_idx = duk_push_object(ctx);
    {% else %}
    duk_push_object(ctx);
    {% endif %}

    {%- if f.array_flag or f.return_array -%}
        {%- if not f.array_in_flag -%}
    duk_size_t i;
        {% endif %}
    {% endif %}

    {%- if f.return_basic_type_full == 'void' -%}
    {{ f.call_func }};
    {% else %}
    {{ f.return_type_full }} res = {{ f.call_func }};

    {% if f.return_basic_type == "char" and f.return_pointer %}
    duk_push_string(ctx, res);
        {%- else -%}
            {% if f.return_array %}
    duk_idx_t obj_idx_return;
    obj_idx_return = duk_push_array(ctx);
    for (i = 0; i < {{ f.return_array_count }}; i++){
        duk_push_number(ctx, res[i]);
        duk_put_prop_index(ctx, obj_idx_return, i);
    }
            {% else %}
                {%- if f.return_pointer -%}
                    {% set v = '*' %}
                {%- endif -%}
    duk_push_number(ctx, {{ v }}res);
            {% endif %}
    {% endif %}
    duk_put_prop_string(ctx, obj_idx, "{{ f.name }}");
    {% endif %}


    {%- for i, p in enumerate(f.out_p) -%}
        {%- if p.final_type == "string" -%}
    duk_push_string(ctx, iotace_{{ p.name }});
    duk_put_prop_string(ctx, obj_idx, "{{ p.name }}");
        {% else %}
            {%- if not p.array -%}
    duk_push_number(ctx, iotace_{{ p.name }});
    duk_put_prop_string(ctx, obj_idx, "{{ p.name }}");
            {% else %}
    {% set array_name = 'obj_idx_iotace_' + p.name %}
    duk_idx_t {{ array_name }};
    {{ array_name }} = duk_push_array(ctx);
    for (i = 0; i < {{ p.array_count }}; i++){
        duk_push_number(ctx, iotace_{{ p.name }}[i]);
        duk_put_prop_index(ctx, {{ array_name }}, i);
    }
    duk_put_prop_string(ctx, obj_idx, "{{ p.name }}");
            {% endif %}{% endif %}{% endfor %}

    {%- for p in f.parameters -%}
        {% if p.array %}
    free(iotace_{{ p.name }});
        {%- endif -%}
    {% endfor %}
    return 1;
}

{% endfor %}


duk_context * ctx;
int iotace_js_init()
{
    ctx = duk_create_heap_default();
    {% for f in functions %}
    duk_push_c_function(ctx, iotace_f_{{ f.name }}, DUK_VARARGS);
    duk_put_global_string(ctx, "{{ f.name }}");
    {% endfor %}
    return 0;
}

int iotace_js_eval(char* script, char* return_string, unsigned int len)
{
    int ret = duk_peval_string(ctx, script);
    
    strncpy(return_string, (char *) duk_safe_to_string(ctx, -1), len);
    duk_pop(ctx);
    
    return ret;
}

int iotace_js_uninit()
{
    duk_destroy_heap(ctx);
    return 0;
}
