import src.template_engine as tmp
import src.build_data as bd
import os
import shutil
import src.decorate_params as decor


def _build_dep():
    if not os.path.isdir(bd.config["build_path"] + '/jerryscript'):
        os.mkdir(bd.config["build_path"] + '/jerryscript')

    for f in os.listdir(bd.__src_dir__ + '/vendors/jerryscript'):
        shutil.copy(bd.__src_dir__ + '/vendors/jerryscript' + '/' + f, bd.config["build_path"] +'/jerryscript/'+ f)


def build():
    _build_dep()
    
    jerryscript = tmp.render_tpl('jerryscript', 'jerryscript.tpl', {"functions": bd.functions, "header_name": bd.header_name})
    with open(bd.config["build_path"] + '/jerryscript/%s_jerryscript.c' % bd.config["program_name"], "wt") as f:
        f.write(jerryscript)

    

