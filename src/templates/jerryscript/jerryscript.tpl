#include "jerryscript.h"
#include <stdio.h>
#include <string.h>
#include "{{header_name}}"

{% for f in functions %}

jerry_value_t  iotace_f_{{ f.name }} (const jerry_value_t func_value, 
                                        const jerry_value_t this_value, 
                                        const jerry_value_t *args_p, 
                                        const jerry_length_t args_cnt) 
{
    {% for p in f.parameters %}
        {%- if p.final_type == "string" -%}
    char* iotace_{{ p.name }};
        {%- elif not p.array -%}
    {{ p.type }} iotace_{{ p.name }};
        {% endif %}
    {% endfor %}

    {%- if f.array_in_flag -%}
    jerry_length_t i;
    jerry_length_t n;
    {% endif %}

    {%- for i,p in enumerate(f.in_p) -%}
        {%- if p.final_type == "string" -%}
    jerry_size_t req_sz_{{ p.name }} = jerry_get_string_size(args_p[{{ i }}]);
    jerry_char_t jry_{{ p.name }}[req_sz_{{ p.name }}+1];
    jerry_string_to_char_buffer(args_p[{{ i }}], jry_{{ p.name }}, req_sz_{{ p.name }});
    jry_{{ p.name }}[req_sz_{{ p.name }}] = '\0';

    iotace_{{ p.name }} = (char *) jry_{{ p.name }};
        {%- elif not p.array -%}
    iotace_{{ p.name }} = ({{p.type}}) jerry_get_number_value(args_p[{{ i }}]);
        {% endif %}
    {% endfor %}

    {%- for p in f.parameters -%}
        {%- if p.array -%}
            {%- if p.final_type == "string" -%}
    {{ p.type_full }} tmp_iotace_{{ p.name }} = ({{ p.type_full }}) calloc({{ p.array_count }}, sizeof({{ p.element_type }}));
                {% if p.route == "in/out" %}
    strcpy(tmp_iotace_{{ p.name }}, iotace_{{ p.name }});
                {% endif %}
    iotace_{{ p.name }} = tmp_iotace_{{ p.name }};
    
    {% else %}
    {{ p.type_full }} iotace_{{ p.name }} = ({{ p.type_full }}) calloc({{ p.array_count }}, sizeof({{ p.element_type }}));
            {% endif %}{% endif %}{% endfor %}


    {%- for i, p in enumerate(f.in_p) -%}
        {% if p.array and p.final_type != "string" %}
    n = jerry_get_array_length(args_p[{{ i }}]);
    jerry_value_t ar_value;
    for (i = 0; i < n; i++) {
        ar_value = jerry_get_property_by_index(args_p[{{ i }}], i);
        iotace_{{ p.name }}[i] = ({{p.type}}) jerry_get_number_value(ar_value);
        jerry_release_value(ar_value);
    }
    {% endif %}
    {%- endfor -%}
    

    jerry_value_t object = jerry_create_object();
    
    {% if f.array_flag or f.return_array %}
    jerry_value_t ar_el;
        {%- if not f.array_in_flag -%}
    jerry_length_t i;
        {% endif %}
    {% endif %}



    {% if f.return_basic_type_full == 'void' %}
    {{ f.call_func }};
    {% else %}
    {{ f.return_type_full }} res = {{ f.call_func }};
    jerry_value_t r_prop_name = jerry_create_string ((const jerry_char_t *) "{{ f.name }}");

    {% if f.return_basic_type == "char" and f.return_pointer %}
    jerry_value_t ret_val = jerry_create_string((const jerry_char_t *) res);
    jerry_set_property(object, r_prop_name, ret_val);
    jerry_release_value(ret_val);

        {%- else -%}
            {% if f.return_array %}
    jerry_value_t ret_array = jerry_create_array({{ f.return_array_count }});
    for (i = 0; i < {{ f.return_array_count }}; i++) {
        ar_el = jerry_create_number(res[i]);
        jerry_set_property_by_index(ret_array, i, ar_el);
        jerry_release_value(ar_el);
    }
    jerry_set_property(object, r_prop_name, ret_array);
    jerry_release_value(ret_array);

            {% else %}
                {%- if f.return_pointer -%}
                    {% set v = '*' %}
                {%- endif -%}
    jerry_value_t ret_number = jerry_create_number({{ v }}res);
    jerry_set_property(object, r_prop_name, ret_number);
    jerry_release_value(ret_number);
            {% endif %}
    {% endif %}

    jerry_release_value(r_prop_name);
    {% endif %}

    {% if len(f.out_p) %}
    
    jerry_value_t value;
    jerry_value_t prop_name;

    {% for i, p in enumerate(f.out_p) %}
    prop_name = jerry_create_string((const jerry_char_t *) "{{p.name}}");
        {% if p.final_type == "string" %}
    value = jerry_create_string((const jerry_char_t *) iotace_{{ p.name }});
    jerry_set_property(object, prop_name, value);
    jerry_release_value(value);
        {% else %}
            {% if not p.array %}
    value = jerry_create_number(iotace_{{ p.name }});
    jerry_set_property(object, prop_name, value);
    jerry_release_value(value);
            {% else %}
    
    value = jerry_create_array({{ p.array_count }});

    for (i = 0; i < {{ p.array_count }}; i++) {
        ar_el = jerry_create_number(iotace_{{ p.name }}[i]);
        jerry_set_property_by_index(value, i, ar_el);
        jerry_release_value(ar_el);
    }
    jerry_set_property(object, prop_name, value);
    jerry_release_value(value);
            {% endif %}{% endif %}
    jerry_release_value(prop_name);
    {% endfor %}

    {%- for p in f.parameters -%}
        {% if p.array %}
    free(iotace_{{ p.name }});
        {%- endif -%}
    {% endfor %}

    {%endif%}
    return object;
}

{% endfor %}


int iotace_js_init()
{
    jerry_init (JERRY_INIT_EMPTY);

    jerry_value_t global_object = jerry_get_global_object ();
    jerry_value_t func_val;
    jerry_value_t prop_name;

    {% for f in functions %}

    func_val = jerry_create_external_function (iotace_f_{{ f.name }});
    prop_name = jerry_create_string ((const jerry_char_t *) "{{ f.name }}");
    jerry_set_property(global_object, prop_name, func_val);
    jerry_release_value(prop_name);
    jerry_release_value(func_val);
    {% endfor %}

    jerry_release_value (global_object);

    return 0;
}


int iotace_js_eval(char* script, char* return_string, unsigned int len)
{
    jerry_value_t ret_val = jerry_eval((const jerry_char_t *) script,
                          strlen(script),
                          false);

    if (jerry_value_has_error_flag(ret_val)) {
        jerry_release_value(ret_val);
        snprintf(return_string, len, "Eval error!");
        return 1;
    }

    if (jerry_value_is_undefined (ret_val))
      snprintf(return_string, len, "undefined");
    else if (jerry_value_is_null (ret_val))
      snprintf(return_string, len, "null");
    else if (jerry_value_is_boolean (ret_val))
        if (jerry_get_boolean_value (ret_val))
            snprintf(return_string, len, "true");
        else
            snprintf(return_string, len, "false");
    else if (jerry_value_is_number(ret_val)) 
        snprintf(return_string, len, "%f", jerry_get_number_value(ret_val));
    else if (jerry_value_is_string (ret_val))
    {
        jerry_size_t req_sz = jerry_get_string_size (ret_val);
        jerry_char_t str_buf_p[req_sz+1];

        jerry_string_to_char_buffer(ret_val, str_buf_p, req_sz);
        str_buf_p[req_sz] = '\0';

        snprintf(return_string, len, "%s", (const char *) str_buf_p);
    }
    else if (jerry_value_is_object (ret_val))
    {
        snprintf(return_string, len, "[JS object]");
    }
    
    jerry_release_value(ret_val);

    return 0;
}

int iotace_js_uninit()
{
    jerry_cleanup();

    return 0;
}