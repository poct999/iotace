{% if "civetweb" in out_list %}
#include "civetweb.h"
int iotace_rest_init();
{% endif %}

/* Instead of header file */
int iotace_js_init();
int iotace_shell_run();

int main(int argc, char *argv[])
{
    iotace_js_init();
    {% if "civetweb" in out_list %}
    iotace_rest_init();
    {% endif %}

    iotace_shell_run();
    
  
    return 0;
}

