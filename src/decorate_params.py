import src.build_data as bd


def get_param_info(type, array, array_count) -> str:
    if type == "void" :
        return "void"

    if type == "string" :
        return "string" if not array else "string[<code>%s</code>]" % array_count

    if type == "number" :
        return "number" if not array else "array[<code>%s</code>] of number" % array_count

    if type == "struct" :
        return "struct" if not array else "array[<code>%s</code>] of struct" % array_count

    return ''



def __change_data_for_render():
    for f in bd.functions:
        for p in f["parameters"]:
            p["js_info"] = get_param_info(p["final_type"], p["array"], p["array_count"])
        f["return_js_info"] = get_param_info(f["return_final_type"], f["return_array"], f["return_array_count"])


        if f["return_basic_type"] == "void" and f["return_pointer"]:
            f["return_type"] = "char"
            f["return_type_full"] = "char*"

        for i, p in enumerate(f["parameters"]):
            if not str(p["array_count"]).isdigit():
                p["array_count"] = 'iotace_' + p["array_count"]

            if not p["name"]:
                p["name"] = "iotace_var_" + str(i)

            if p["basic_type"] == "void" and p["pointer"]:
                p["type"] = "char"
                p["type_full"] = "char*"
                p["element_type"] = "char"

        if not str(f["return_array_count"]).isdigit():
            f["return_array_count"] = 'iotace_' + f["return_array_count"]

        for p in f["parameters"]:
            if p["array"] and p["final_type"] != "string":
                f["array_flag"] = True
                if p["route"] == "in" or p["route"] == "in/out":
                    f["array_in_flag"] = True

        f['in_p'] = [p for p in f["parameters"] if p["route"] == "in" or p["route"] == "in/out"]
        f['out_p'] = [p for p in f["parameters"] if p["route"] == "out" or p["route"] == "in/out"]

        call_args = []
        for p in f["parameters"]:
            if p["pointer"]:
                if p["final_type"] == "string" or p["array"]:
                    call_args.append('iotace_' + p["name"])
                else:
                    call_args.append("&" + 'iotace_' + p["name"])
            else:
                call_args.append('iotace_' + p["name"])

        f["call_func"] = '%s(' % f["name"] + ', '.join(call_args) + ')'
