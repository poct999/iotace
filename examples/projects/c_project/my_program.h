#ifndef MY_PROGRAM_H_
#define MY_PROGRAM_H_

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>


#ifdef __cplusplus
extern "C"{
#endif

/**
 * Ничего не возвращающая функция
 * Return {} check
*/
void empty_func();


/**
 * Сложить два числа типа Integer.
 * Read number
 * Return number
*/
int sum_numbers_int(int v1, int v2);


/**
 * Сложить два числа типа Double.
 * \param v1 [in,]
 * \param v2 []
*/
double sum_numbers_double(double v1, double v2);


/**
 * Получить первое слово в строке.
 * Use [out] string array param 
 * \param result [out, array[buffer_length]]
*/
void get_first_word(char* string, char* result, int buffer_length);


/**
 * Привести строку к верхнему регистру
 * Use string with array flag 
 * \param string [in/out, array[length]]
*/
void string_to_upper(char* string, int length);


/**
 * Вернуть массив, где все значения исходного увеличины на величину num
 * Use [out] number array
 * \param mas [in, array[mas_length]]
 * \param res_mas [out, array[mas_length]]
*/
void inc_array_elements(uint32_t *mas, uint32_t* res_mas, int mas_length, uint32_t num);


/**
 * Обнулить массив и вернуть его
 * Use [in/out] array
 * \param mas [in/out, array[mas_length]]
*/
void clear_mas(int* mas, int mas_length);


/*
 * RETURN ARRAY (18+)
 * Внимание, данные функции были написаны профессионалами.
 * Ни в коем случае не повторяйте это дома.
*/

/**
 * Получить новый массив из input_mas без последнего элемента
 * Внимание, будет утечка памяти!
 * Return number array.
 * \param ret_mas_length [out]
 * \param input_mas [in, array[inp_mas_length]]
 * \return [array[ret_mas_length]]
*/
int* get_mas_without_last_element(int *input_mas, int inp_mas_length, int* ret_mas_length);


/**
 * Получить фразу "HelloWorld" в виде строки
 * Внимание, будет утечка памяти!
 * Return string
*/
char* get_string_HelloWorld();






#ifdef __cplusplus
}
#endif









#endif /* MY_PROGRAM_H_ */
