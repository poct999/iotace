#include "my_program.h"


void empty_func() 
{

}


int sum_numbers_int(int v1, int v2)
{
    return v1 + v2;
}


double sum_numbers_double(double v1, double v2)
{
    return v1 + v2;
}


void get_first_word(char* string, char* result, int buffer_length)
{
    int i = 0;
    while (++i < buffer_length) {
        if (string[i] == ' ' || string[i] == '\0' 
            || string[i] == ',' || string[i] == '.' ) 
            break;
    }
    string[i] = '\0';

    for (i = 0; i < strlen(string); i++)
        result[i] = string[i];
}


void string_to_upper(char* string, int length)
{
    unsigned int i;
    for (i = 0; i < length; i++)
        string[i] = toupper(string[i]);
}


void inc_array_elements(uint32_t *mas, uint32_t* res_mas, int mas_length, uint32_t num)
{
    unsigned int i;
    for (i = 0; i < mas_length; i++)
        res_mas[i] = mas[i] + num;
}


void clear_mas(int* mas, int mas_length)
{
    unsigned int i;
    for (i = 0; i < mas_length; i++)
        mas[i] = 0;
}


int* get_mas_without_last_element(int *input_mas, int inp_mas_length, int* ret_mas_length)
{
    int* mas = (int*) malloc(sizeof(int)*inp_mas_length-1);
    
    unsigned int i;
    for (i = 0; i < inp_mas_length-1; i++)
        mas[i] = input_mas[i];

    *ret_mas_length = inp_mas_length-1;

    return mas;
}


char* get_string_HelloWorld()
{
    char* name = (char*) malloc(sizeof(char) * 100);

    strcpy(name, "HelloWorld");

    return name;
}
















