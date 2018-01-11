#include <unistd.h>

int iotace_init()
{
    return 0;
}

int iotace_read(void *buffer, int nbyte)
{
    return read(STDIN_FILENO, buffer, nbyte);
}

int iotace_write(void *buffer, int nbyte)
{
    return write(STDOUT_FILENO, buffer, nbyte);
}


