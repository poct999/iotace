#include <stdlib.h>
#include <node.h>
#include "{{module_name}}.h"

namespace {{ module_name }} {

    using v8::FunctionCallbackInfo;
    using v8::Isolate;
    using v8::Local;
    using v8::Object;
    using v8::String;
    using v8::Value;
    using v8::Array;
    using v8::Number;


    {% for f in functions %}
    void iotace_{{ f.name }}(const FunctionCallbackInfo<Value>& args)
    {
        Isolate* isolate = args.GetIsolate();
        Local<Object> result = Object::New(isolate);

        {% for p in f.parameters %}
            {%- if p.final_type == "string" -%}
        char* iotace_{{ p.name }};
            {%- elif not p.array -%}
        {{ p.type }} iotace_{{ p.name }};
            {% endif %}
        {% endfor %}

        {%- if f.array_in_flag -%}
        unsigned int i;
        unsigned int n;
        {% endif %}

        {%- for i,p in enumerate(f.in_p) -%}
            {%- if p.final_type == "string" -%}
        String::Utf8Value string_iotace_{{ p.name }}(args[{{ i }}]);
        iotace_{{ p.name }} = (char*) *string_iotace_{{ p.name }};
            {%- elif not p.array -%}
        iotace_{{ p.name }} = args[{{ i }}]->NumberValue();
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
        Local<Array> array_iotace_{{ p.name }} = Local<Array>::Cast(args[{{ i }}]);
        n = array_iotace_{{ p.name }}->Length();
        for (i = 0; i < n; i++) {
            iotace_{{ p.name }}[i] = array_iotace_{{ p.name }}->Get(i)->NumberValue();
        }
        {% endif %}
        {%- endfor -%}

        {%- if f.array_flag or f.return_array -%}
            {%- if not f.array_in_flag -%}
        unsigned int i;{% endif %}{% endif %}
        
        {% if f.return_basic_type_full == 'void' %}
        {{ f.call_func }};
        {% else %}
        {{ f.return_type_full }} res = {{ f.call_func }};

        {% if f.return_basic_type == "char" and f.return_pointer %}
        result->Set(String::NewFromUtf8(isolate, "{{ f.name }}"), String::NewFromUtf8(isolate, res));
            {%- else -%}
                {% if f.return_array %}
        Local<Array> array_return = Array::New(isolate);
        for (i = 0; i < {{ f.return_array_count }}; i++){
            array_return->Set(i, Number::New(isolate, res[i]));
        }
        result->Set(String::NewFromUtf8(isolate, "{{ f.name }}"), array_return);
                 {% else %}
                    {%- if f.return_pointer -%}
                        {% set v = '*' %}
                    {%- endif -%}
        result->Set(String::NewFromUtf8(isolate, "{{ f.name }}"), Number::New(isolate, {{ v }}res));
                {% endif %}
        {% endif %}
        {% endif %}


        {%- for i, p in enumerate(f.out_p) -%}
            {%- if p.final_type == "string" -%}
        result->Set(String::NewFromUtf8(isolate, "{{ p.name }}"), String::NewFromUtf8(isolate, iotace_{{ p.name }}));
            {% else %}
                {%- if not p.array -%}
        result->Set(String::NewFromUtf8(isolate, "{{ p.name }}"), Number::New(isolate, iotace_{{ p.name }}));
                {% else %}
        {% set array_name = 'obj_idx_iotace_' + p.name %}
        Local<Array> {{ array_name }} = Array::New(isolate);
        for (i = 0; i < {{ p.array_count }}; i++) {
            {{ array_name }}->Set(i, Number::New(isolate, iotace_{{ p.name }}[i]));
        }
        result->Set(String::NewFromUtf8(isolate, "{{ p.name }}"), {{ array_name }});
                {% endif %}{% endif %}{% endfor %}

        {%- for p in f.parameters -%}
            {% if p.array %}
        free(iotace_{{ p.name }});
            {%- endif -%}
        {% endfor %}

        args.GetReturnValue().Set(result);
    }
    {% endfor %}


    void Init(Local<Object> exports)
    {
    {% for f in functions %}
        NODE_SET_METHOD(exports, "{{ f.name }}", iotace_{{ f.name }});
    {% endfor %}
    }

    NODE_MODULE({{ module_name }}, Init)

}
