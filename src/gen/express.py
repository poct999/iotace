import src.template_engine as tmp
import src.build_data as bd
import os
import shutil
import src.decorate_params as decor


def _build_html() -> str:
    result = tmp.render_tpl('express', 'index.tpl',
                            {"functions": bd.functions, "module_name": bd.config["program_name"]})

    return result


def _build_js() -> str:
    result = tmp.render_tpl('express', 'server.tpl',
                            {"functions": bd.functions, "module_name": bd.config["program_name"]})

    return result

def _build_package() -> str:
    result = tmp.render_tpl('express', 'package.tpl',
                            {"module_name": bd.config["program_name"]})

    return result

def _build_run_server_src():
    result = tmp.render_tpl('express', 'run_server.tpl',
                            {"module_name": bd.config["program_name"]})

    return result


def build():
    module_dir = bd.config["build_path"] + '/%s_server'%bd.config["program_name"]
    if not os.path.isdir(module_dir):
        os.mkdir(module_dir)


    views_dir = module_dir + '/views'
    if not os.path.isdir(views_dir):
        os.mkdir(views_dir)


    html_src = _build_html()
    server_src = _build_js()
    package_src = _build_package()
    run_server_src = _build_run_server_src()


    with open(views_dir + '/main.html', "wt") as fl:
        fl.write(html_src)

    with open(module_dir + '/server.js', "wt") as fl:
        fl.write(server_src)

    with open(module_dir + '/package.json', "wt") as fl:
        fl.write(package_src)

    with open(bd.config["build_path"] + '/run_server.js', "wt") as fl:
        fl.write(run_server_src)



