#include <ti/drivers/UART.h>
#include "Board.h"

UART_Handle uart;

int iotace_init()
{
    UART_Params uartParams;
    UART_init();
    UART_Params_init(&uartParams);
    uartParams.writeDataMode = UART_DATA_BINARY;
    uartParams.readDataMode = UART_DATA_BINARY;
    uartParams.readReturnMode = UART_RETURN_FULL;
    uartParams.readEcho = UART_ECHO_OFF;
    uartParams.baudRate = 115200;

    uart = UART_open(Board_UART0, &uartParams);

    if (uart == NULL) {
        return 1;
    }

    return 0;
}

int iotace_read(void *buffer, int nbyte)
{
    return UART_read(uart, buffer, nbyte);
}

int iotace_write(void *buffer, int nbyte)
{
    return UART_write(uart, buffer, nbyte);
}


