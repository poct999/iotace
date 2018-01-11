import json

ERRORS_LIST = {
    0: {
        "message": "Undefined error"
    },
    1: {
        "message": "Return value is not pointer, but specified as array."
    },
    2: {
        "message": "Variable has unsupported type.",
        "help": "Make wrapper without structure"
    },
    3: {
        "message": "Variable is not pointer, but specified as array."
    },
    4: {
        "message": "Variable has string type, but you didn't specify buffer size.",
        "help": "Use '[out, array[size]]' specifier."
    },
    5: {
        "message": "Variable will be used as char array.",
        "help": "Try changing variable type to clarify."
    },
    6: {
        "message": "Variable has unsupported type.",
        "help": "Too many pointers"
    },
    7: {
        "message": "Header parse error", 
        "help": "Check syntax in your file"
    },
    8: {
        "message": "Config parse error"
    }
}


ERROR_TYPE = 'error'
WARNING_TYPE = 'warning'
NOTIFICATION_TYPE = 'notification'


notices_list = []

# DEFAULT_NOTICE = {
#     'id': None,
#     'type': None,
#     'message': None,
#     'line': None,
#     'offset': None,
#     'funcName': None,
#     'paramName': None,
#     'help': None,
# }


def add_notice(notice):
    # tmp = DEFAULT_NOTICE.copy()
    # tmp.update(notice)
    # notices_list.append(tmp)
    notices_list.append(notice)

def add_error(error):
    error['type'] = ERROR_TYPE
    add_notice(error)

def add_error_by_id(id, help = ""):
    ntc = {
        "id": id,
    }
    ntc.update(ERRORS_LIST[id])
    
    if help: 
        ntc["help"] = help

    add_error(ntc)

def add_error_by_id_and_exit(id, help = ""):
    add_error_by_id(id, help)
    print(get_notice_list_json())
    exit(1)

def add_warning(warning):
    warning["type"] = WARNING_TYPE
    add_notice(warning)

def add_notification(notification):
    notification["type"] = NOTIFICATION_TYPE
    add_notice(notification)


def get_notice_list_json():
    return json.dumps(notices_list)



def get_notice_from_function(func, id = 0):
    ntc = {
        "id": id,
        "funcName": func["name"],
        "line": func["line_number"]
    }
    ntc.update(ERRORS_LIST[id])
    
    return ntc


def get_notice_from_param(func, param, id = 0):
    ntc = get_notice_from_function(func, id)
    ntc["paramName"] = param["name"]
    ntc["line"] = param["line_number"]
    
    return ntc


def get_errors_count():
    count = len([i for i in notices_list if i["type"] == ERROR_TYPE])

    return count


def exit_if_errors():
    if (get_errors_count()):
        print(get_notice_list_json())
        exit(1)

