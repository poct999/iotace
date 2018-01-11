import src.build_data as bd
from pycparser import c_ast, parse_file, plyparser
from CppHeaderParser import *
import src.notice as notice

__src_dir = os.path.dirname(__file__)
__work_dir = os.path.dirname(__src_dir)

c_include = __src_dir + '/include'


def check_decl(func_decl):
    exit_flag = 0
    for f in func_decl:
        if not f["return_pointer"] and f["return_array"]:
            ntc = notice.get_notice_from_function(f, 1)
            notice.add_error(ntc)
            exit_flag = 1

        for p in f["parameters"]:

            if p["final_type"] == "struct":
                ntc = notice.get_notice_from_param(f, p, 2)
                notice.add_error(ntc)
                exit_flag = 1

            if str(p["basic_type_full"]).count("*") > 1:
                ntc = notice.get_notice_from_param(f, p, 6)
                notice.add_error(ntc)
                exit_flag = 1

            if not p["pointer"] and p["array"]:
                ntc = notice.get_notice_from_param(f, p, 3)
                notice.add_error(ntc)
                exit_flag = 1

            if p["type"] == "char" \
                    and (p["route"] == "out" or p["route"] == "in/out") \
                    and not p["array"]:
                ntc = notice.get_notice_from_param(f, p, 4)
                notice.add_warning(ntc)

            if p["basic_type"] == "void" and p["pointer"]:
                ntc = notice.get_notice_from_param(f, p, 5)
                notice.add_warning(ntc)


    notice.exit_if_errors()


def set_c_include(path = ''):
    global c_include
    c_include = path


def _explain_full_type(decl):
    typ = type(decl)

    if typ == c_ast.TypeDecl:
        return _explain_full_type(decl.type)
    if typ == c_ast.Decl or typ == c_ast.Typename:
        arr = ''
        if type(decl.type) == c_ast.ArrayDecl:
            arr = '[]'
            if decl.type.dim: arr = '[%s]' % decl.type.dim.value

        if decl.name:
            return _explain_full_type(decl.type) + ' ' + decl.name + arr
        else:
            return _explain_full_type(decl.type) + arr
    if typ == c_ast.IdentifierType:
        return ''.join(decl.names)
    if typ == c_ast.PtrDecl:
        return _explain_full_type(decl.type) + '*'
    if typ == c_ast.ArrayDecl:
        return _explain_full_type(decl.type)


def _explain_name(decl):
    typ = type(decl)
    if typ == c_ast.Decl or typ == c_ast.Typename:
        if decl.name:
            return  decl.name
    return _explain_type(decl.type)


def _explain_type(decl):
    typ = type(decl)

    if typ == c_ast.IdentifierType:
        return ' '.join(decl.names)

    if typ == c_ast.Struct:
        name = decl.name if decl.name else ''
        return "struct " + name

    if typ == c_ast.PtrDecl:
        return _explain_type(decl.type) + '*'

    return _explain_type(decl.type)


class FuncDeclVisitor(c_ast.NodeVisitor):
    result = {}
    typedef = {}

    def visit_Decl(self, node):
        decl = node.type

        if (type(decl) == c_ast.FuncDecl):
            params, short_params, names = [], [], []
            if decl.args:
                short_params = [_explain_type(param) for param in decl.args.params]
                names = [_explain_name(param) for param in decl.args.params]

            name = node.name
            self.result[name] = {"return_type": _explain_full_type(decl.type),
                                 "parameters": short_params}

    def visit_Typedef(self, node):
        decl = node.type

        self.typedef[node.name] = _explain_type(decl)


def _parse(file=''):
    cpp_args = r'-I%s' % (c_include) if c_include else ''

    parse = None
    try:
        parse = parse_file(file, use_cpp=True, cpp_args=cpp_args)
    except plyparser.ParseError as e:
        notice.add_error_by_id(7)
        notice.exit_if_errors()

    return parse
    # return parse_file(file, use_cpp=True)


def _get_types(typedef):
    basic_type = {}
    element_type = {}
    for k in typedef:
        nk, point, one_el_type = k, 0, None

        while typedef.get(k, None):
            k = typedef.get(k, None)
            point += k.count("*")
            k = k.replace('*', '')
            if not one_el_type and point:
                one_el_type = k

        one_el_type = one_el_type if one_el_type else nk
        element_type[nk] = one_el_type
        basic_type[nk] = k + "*" * point
    return (basic_type, element_type)


param_metadata_re = r"\[\s*(in/out|out|in)" \
      r"\s*,?\s*(?:(array)\[([a-zA-Z_0-9]+)\])?\s*\]"


def get_build_data():
    header = bd.config["header"]
    v = FuncDeclVisitor()
    v.visit(_parse(header))
    pp_func_decl = v.result

    basic_type, element_type = _get_types(v.typedef)

    CppHeaderParser.print_warnings = 0
    funcs = CppHeader(header).functions


    func_decl = []
    for f in funcs:
        func = {}

        func["prototype"] = f["debug"]
        func["name"] = f["name"]
        func["line_number"] = f["line_number"]

        tpy = pp_func_decl[func["name"]]["return_type"]
        func["return_type_full"] = tpy
        clr_tpy = tpy.replace('*', '')
        func["return_type"] = clr_tpy

        func["return_basic_type_full"] = basic_type.get(clr_tpy, clr_tpy) + str(tpy).count("*")*"*"
        func["return_basic_type"] = func["return_basic_type_full"].replace('*','')

        func["return_pointer"] = f["returns_pointer"]

        func_params = []
        params = f.get("parameters", None)

        for (i,p) in enumerate(params):
            my_p = {}

            my_p["name"] = p["name"]
            my_p["line_number"] = p["line_number"]

            tpy = pp_func_decl[func["name"]]["parameters"][i]
            my_p["type_full"] = tpy
            clr_tpy = tpy.replace('*', '')
            my_p["element_type"] = element_type.get(clr_tpy, clr_tpy)
            my_p["type"] = clr_tpy
            my_p["basic_type_full"] = basic_type.get(clr_tpy, clr_tpy) + str(tpy).count("*")*"*"
            my_p["basic_type"] = my_p["basic_type_full"].replace('*','')

            my_p["pointer"] = p["pointer"]

            if my_p["type"] == "void" and not my_p["pointer"]:
                continue

            desc = p.get("desc", "[in]")
            find = re.findall(param_metadata_re, desc)
            if not find:
                find = re.findall(param_metadata_re, "[in]")

            my_p["route"] = find[0][0]
            my_p["array"] = 1 if find[0][1] else 0
            my_p["array_count"] = find[0][2]

            if my_p["basic_type"] == "char" and my_p["pointer"]:
                my_p["final_type"] = "string"
            elif str(my_p["basic_type"]).split(' ')[0] == "struct":
                my_p["final_type"] = "struct"
            else:
                my_p["final_type"] = "number"

            # print(my_p["name"])
            # print(my_p["final_type"])
            # print("############")
            func_params.append(my_p)


        desc = f.get("doxygen", "\\return []")
        _re = r"\\return\s+\[\s*(?:(array)\[([a-zA-Z_0-9]+)\])?\s*\]"
        find = re.findall(_re, desc)
        if not find:
            find = re.findall(_re, "\\return []")

        func["return_array"] = 1 if find[0][0] else 0
        func["return_array_count"] = find[0][1]

        if func["return_basic_type_full"] == "void" and not func["return_pointer"]:
            func["return_final_type"] = "void"
        elif func["return_basic_type"] == "char" and func["return_pointer"]:
            func["return_final_type"] = "string"
        elif str(func["return_basic_type"]).split(' ')[0] == "struct":
            func["return_final_type"] = "struct"
        else:
            func["return_final_type"] = "number"

        func["parameters"] = func_params
        func_decl.append(func)


    bd.functions = func_decl

    for i, f in enumerate(bd.functions):
        f["input_args"] = ', '.join(
            [m["type_full"] + ' ' + m["name"] for m in f["parameters"] if
             m["route"] == "in" or m["route"] == "in/out"])
        f["input_unknown_args"] = ', '.join(
            ["?" for m in f["parameters"] if m["route"] == "in" or m["route"] == "in/out"])

        f["args"] = ', '.join([m["type_full"] + ' ' + m["name"] for m in f["parameters"]])

        f['doxygen'] = funcs[i].get('doxygen', '')
        f['html_doxygen'] = f['doxygen']
        if f['html_doxygen']:
            f['html_doxygen'] = '\n'.join([str(l).strip().lstrip('*').strip() + '<br />'
                                      for l in f['html_doxygen'].replace('/*', '').replace('*/', '').split('\n')])
            f['html_doxygen'] = re.sub(r"\\param\s*([^\s]*)", r"\\param <b>\1</b>", f['html_doxygen'])
        


    # from pprint import pprint
    # pprint(bd.functions) 
