import argparse
import src.build_data as bd
import src.parser as pars
import re
import CppHeaderParser


__header__ = ''
__save_to__ = ''




def get_full_param_info(type, route, array, array_count) -> str:
    r = '[' + route + '] ' if route else ''

    return r + ' ' + get_param_info(type, array, array_count)


def get_func_info(f):
    result = ''
    p = ', '.join([m["type_full"] + ' ' + m["name"] for m in f["parameters"]])
    descr = f["return_type_full"] + ' ' + f["name"] + '(' + p + ')'
    result += descr

    result += '\n\t> return: ' + get_param_info(f['return_final_type'], None, f['return_array'], f['return_array_count'])

    for p in f["parameters"]:
        result += '\n\t> %s: '%p["name"] + get_param_info(p['final_type'], p['route'], p['array'], p['array_count'])

    return result


def print_current_state():
    for i, f in enumerate(bd.data["func_decl"]):
        func_info = get_func_info(f)
        print('[' + str(i + 1) + ']' + ': ' + func_info)
        print()


def print_func_state(f):
    p = ', '.join([m["type_full"] + ' ' + m["name"] for m in f["parameters"]])
    descr = f["return_type_full"] + ' ' + f["name"] + '(' + p + ')'
    result = '\n' + descr

    result += '\n\t[0] return: ' + get_param_info(f['return_final_type'], None, f['return_array'], f['return_array_count'])

    for i,p in enumerate(f["parameters"]):
        result += '\n\t[%d] %s: '%(i+1, p["name"]) + get_param_info(p['final_type'], p['route'], p['array'], p['array_count'])

    print(result)


def edit_param(param):
    print(param["name"] + ": " + get_param_info(param['final_type'], param['route'], param['array'], param['array_count']))
    while True:
        inp = input("Enter metadata (Enter 'q' to break): \n")
        if (inp == 'q'):
            break

        find = re.findall(pars.param_metadata_re, inp)
        if not find:
            print("[ERROR]: Incurrect input")
        else:
            param["route"] = find[0][0]
            param["array"] = 1 if find[0][1] else 0
            param["array_count"] = find[0][2]
            break


def edit_return(func):
    print("return: " + get_param_info(func['return_final_type'], None, func['return_array'],
                                                func['return_array_count']))
    while True:
        inp = input("Enter metadata (Enter 'q' to break): \n")
        if (inp == 'q'):
            break
        _re = r"\[\s*(?:(array)\[([a-zA-Z_0-9]+)\])?\s*\]"
        find = re.findall(_re, inp)
        if not find:
            print("[ERROR]: Incurrect input")
        else:
            func["return_array"] = 1 if find[0][0] else 0
            func["return_array_count"] = find[0][1]
            break


def gen_metada(route, array, array_count):
    if not array and not route:
        return ''

    result = '['
    result += route if route else ''
    if array:
        if route:
            result += ', '
        result += 'array[%s]' % array_count
    result += ']'

    return result


def save():
    with open(__header__, "r") as f:
        src_header = f.readlines()

    cHeader = CppHeaderParser.CppHeader(__header__)

    for i,f in enumerate(cHeader.functions):
        rf = bd.data["func_decl"][i]

        doxy = '/**\n * %s\n' % rf['name']
        doxy += ' * \\return %s\n' % gen_metada('', rf['return_array'], rf['return_array_count'])
        for p in rf["parameters"]:
            doxy += ' * \\param %s %s \n'%(str(p['name']), str(gen_metada(p['route'], p['array'], p['array_count'])))
        doxy += '*/\n'


        line = f["line_number"] - 1
        src_header[line:line] = map(lambda l:l+'\n',doxy.splitlines())

        num = len(doxy.splitlines())
        for ff in cHeader.functions: ff["line_number"] += num

    with open(__save_to__, "wt") as f:
        f.writelines(src_header)




def edit_function(func):
    print_func_state(func)
    while True:
        choose = input("\nChoose item for edit (Enter 'q' to return main menu): \n")
        if choose == 'q':
            break

        if not str(choose).isnumeric():
            print("[ERROR]: Incurrect input")
            continue
        if int(choose) > len(func["parameters"]) or int(choose) < 0:
            print("[ERROR]: Out of range function list")
            continue

        if int(choose) > 0:
            edit_param(func["parameters"][int(choose)-1])
            print_func_state(func)
        else:
            edit_return(func)
            print_func_state(func)


def main_menu():
    print_current_state()
    while True:
        choose = input("\nChoose function for edit (Enter 'q' to exit, Enter 'w' to save): \n")
        if choose == 'q':
            break
        if choose == 'w':
            save()
            print("\nSaved in folder: %s" % __save_to__)
            break

        if not str(choose).isnumeric():
            print("[ERROR]: Incurrect input")
            continue
        if int(choose) > len(bd.data["func_decl"]) or int(choose) < 1:
            print("[ERROR]: Out of range function list")
            continue

        edit_function(bd.data["func_decl"][int(choose)-1])
        print_current_state()

def go():
    bd.data["header"] = __header__
    pars.get_build_data()
    pars.check_decl(bd.data["func_decl"])
    main_menu()


if __name__ == "__main__":
    ap = argparse.ArgumentParser(description="""
    EXAMPLE:
    ./configure_header.py --header="/home/user/temp/my_program.h" --save_to="/home/user/temp/res/my_program.h"
    """,
                                 prog='IoTace Configuration Tool')

    ap.add_argument("--header", required = True, help = "path to header of the library")
    ap.add_argument("--save_to", required = False, help = "path to the directory where we save result")
    args = vars(ap.parse_args())


    if not args["save_to"]:
        print("WARNING: current header will be overwritten!")
        args["save_to"] = args["header"]


    __header__ = args["header"]
    __save_to__ = args["save_to"]

    go()






