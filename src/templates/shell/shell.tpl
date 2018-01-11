#include <string.h>

#define SHELL_LINE_SIZE 1024

int iotace_js_eval(char*, char*, unsigned int);


{{ target_shell }}


int iotace_shell_print(char *string)
{
    return iotace_write(string, strlen(string));
}


int iotace_shell_scan(char *string, int len)
{
    char c;
    int cnt = 0;
    while (cnt++ != len) {
        iotace_read(&c, 1);

        if((*string++ = c) == '\n') {
            string[-1] = '\0';
            break;
        }
    }

    return cnt;
}

char buf[SHELL_LINE_SIZE];
int iotace_shell_run()
{
    if (iotace_init()) {
        return 1;
    }

    for (;;) {
        iotace_shell_scan(buf, SHELL_LINE_SIZE);
        iotace_js_eval(buf, buf, SHELL_LINE_SIZE);
        iotace_shell_print(buf);
        iotace_shell_print("\n");
    }

    return 0;
}
