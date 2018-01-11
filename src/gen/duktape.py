import src.template_engine as tmp
import src.build_data as bd
import os
import shutil
import src.decorate_params as decor


def _build_dep():
    if not os.path.isdir(bd.config["build_path"] + '/duktape'):
        os.mkdir(bd.config["build_path"] + '/duktape')

    for f in os.listdir(bd.__src_dir__ + '/vendors/duktape'):
        shutil.copy(bd.__src_dir__ + '/vendors/duktape' + '/' + f, bd.config["build_path"] +'/duktape/'+ f)


def build():
    _build_dep()
    
    duktape = tmp.render_tpl('duktape', 'duktape.tpl', {"functions": bd.functions, "header_name": bd.header_name})
    with open(bd.config["build_path"] + '/duktape/%s_duktape.c' % bd.config["program_name"], "wt") as f:
        f.write(duktape)

    

