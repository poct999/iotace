import json
import src.notice as notice
import src.build_data as bd
import os

def parse(file_name):

    try:
        with open(file_name) as f:    
            data = json.load(f)
    except:
        notice.add_error_by_id_and_exit(8)

    if not data.get("header", None):    
        notice.add_error_by_id_and_exit(7, "Empty header path")


    bd.config.update(data)

    bd.config["header"] = os.path.abspath(bd.config["header"])
    if not os.path.isfile(bd.config["header"]):
        notice.add_error_by_id_and_exit(7, "No such file")

    
    bd.config["build_path"] = os.path.abspath(bd.config["build_path"])

    if not len(bd.config["out"].keys()): 
        bd.config["out"]["nodered"] = {}
    
    empty_out = {
        "include": [],
        "source": [],	
        "libs": [],
        "flags": []
    }
    for k in data["out"].keys():
        if k == "shell" or k == "nodejs":
            ot = empty_out.copy()
            ot.update(bd.config["out"][k])
            bd.config["out"][k] = ot

            bd.config["out"][k]["source"] = [os.path.abspath(s) for s in bd.config["out"][k]["source"]]

        if k == "shell":
            if not bd.config["out"][k].get("target", None):
                bd.config["out"][k]["target"] = "targets/linux"

            bd.config["out"][k]["target"] = os.path.abspath(bd.config["out"][k]["target"])
            
            bd.config["out"][k]["with_app"] = bd.config["out"][k].get("with_app", True)
    


    bd.header_name = os.path.basename(bd.config["header"])
    
    if bd.config["header_path"]:
        header_path = os.path.dirname(bd.config["header_path"])
        bd.config["include"].append('-I' + header_path)

    if not bd.config["program_name"]:
        name = str(bd.header_name)[:str(bd.header_name).rfind('.')]
        bd.config["program_name"] = name if name else bd.header_name


    # from pprint import pprint 
    # pprint(bd.config)
    # exit(1)