import src.template_engine as tmp
import src.build_data as bd
import os
import shutil
import src.decorate_params as decor


def _build_dep():
    if not os.path.isdir(bd.config["build_path"] + '/civetweb'):
        os.mkdir(bd.config["build_path"] + '/civetweb')

    for f in os.listdir(bd.__src_dir__ + '/vendors/civetweb'):
        shutil.copy(bd.__src_dir__ + '/vendors/civetweb' + '/' + f, bd.config["build_path"] + '/civetweb/'+ f)


def build():
    _build_dep()

    civetweb = tmp.render_tpl('civetweb', 'civetweb.tpl', {
        "functions": bd.functions, 
        "out_list": list(bd.config["out"].keys())
    })
    with open(bd.config["build_path"] + '/civetweb/%s_civetweb.c' % bd.config["program_name"], "wt") as f:
        f.write(civetweb)

    