import src.template_engine as tmp
import src.build_data as bd
import os
import shutil



def _build_dep():
    global nodejs_dir
    nodejs_dir = bd.config["build_path"] + '/%s_uart_client' % bd.config["program_name"]
    if not os.path.isdir(nodejs_dir):
        os.mkdir(nodejs_dir)


def build():
    _build_dep()    

    package = tmp.render_tpl('nodejs_uart_client', 'package.tpl', {"module_name": bd.config["program_name"]})

    main_js = tmp.render_tpl('nodejs_uart_client', 'main_js.tpl', {"functions": bd.functions, "module_name": bd.config["program_name"]})

    with open(nodejs_dir + '/%s.js' % (bd.config["program_name"]), "wt") as f:
        f.write(main_js)

    with open(nodejs_dir + '/package.json', "wt") as f:
        f.write(package)
