#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>


#ifdef __cplusplus
extern "C"{
#endif

struct test {
    int l;
    float m;
};

int fail1(int*** v1, int v2);

void* fail2(double v1, double v2);

void fail3(char* string, void* result, int buffer_length);

int fail4(struct test v1, int v2);


#ifdef __cplusplus
}
#endif









