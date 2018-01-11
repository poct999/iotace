import unittest
import requests


__API_URL__ = 'http://127.0.0.1:8888/api/v1'

call_function = lambda m,p:requests.post(__API_URL__,data = {"method":m,"params":p,"jsonrpc":"2.0","id":"1"}).text.strip()
call_api = lambda d:requests.post(__API_URL__,data = d).text.strip()

ret_string = lambda data:'{"jsonrpc":"2.0","result":%s,"id":1}' % data


class c_project_APITest(unittest.TestCase):

    def test_api_empty_query(self):
        self.assertEqual(
            call_api({}),
            '{"jsonrpc":"2.0","error":{"code":-32700,"message":"Parse error"},"id":null}'
        )


    def test_api_function_without_result(self):
        self.assertEqual(
            call_function('empty_func','[]'),
            ret_string('{}')
        )


    def test_api_get_number_int(self):
        self.assertEqual(
            call_function('sum_numbers_int','[140,124]'),
            ret_string('{"sum_numbers_int":264}')
        )


    def test_api_get_number_double(self):
        self.assertEqual(
            call_function('sum_numbers_double','[64.4,4352.5]'),
            ret_string('{"sum_numbers_double":4416.9}')
        )


    def test_api_get_string_by_pointer(self):
        self.assertEqual(
            call_function('get_first_word','["Hi,i`m string",10]'),
            ret_string('{"result":"Hi"}')
        )


    def test_api_get_use_inout_on_string(self):
        self.assertEqual(
            call_function('string_to_upper','["make me grate",20]'),
            ret_string('{"string":"MAKE ME GRATE"}')
        )


    def test_api_array(self):
        self.assertEqual(
            call_function('inc_array_elements','[[1,6,3,11],4,5]'),
            ret_string('{"res_mas":[6,11,8,16]}')
        )


    def test_api_inout_array(self):
        self.assertEqual(
            call_function('clear_mas','[[1,4,5,6,9,7],6]'),
            ret_string('{"mas":[0,0,0,0,0,0]}')
        )


    def test_api_return_array(self):
        self.assertEqual(
            call_function('get_mas_without_last_element','[[1,6,72,12,4],5]'),
            ret_string('{"get_mas_without_last_element":[1,6,72,12],"ret_mas_length":4}')
        )


    def test_api_return_string(self):
        self.assertEqual(
            call_function('get_string_HelloWorld','[]'),
            ret_string('{"get_string_HelloWorld":"HelloWorld"}')
        )




    def test_api_get_number_int_obj(self):
        self.assertEqual(
            call_function('sum_numbers_int','{"v1":140,"v2":124}'),
            ret_string('{"sum_numbers_int":264}')
        )



#TODO
class TestIncorrectApi(unittest.TestCase):
    def test_api_string(self):
        self.assertEqual(1,1)



if __name__ == "__main__":
    unittest.main()
    


