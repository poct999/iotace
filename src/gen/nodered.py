import src.template_engine as tmp
import src.build_data as bd
import os
import shutil
import src.decorate_params as decor


def _build_html(i) -> str:
    result = tmp.render_tpl('nodered', 'html.tpl',
                            {"function": bd.functions[i], "module_name": bd.config["program_name"]})

    return result


def _build_js(i) -> str:
    result = tmp.render_tpl('nodered', 'js.tpl',
                            {"function": bd.functions[i], "module_name": bd.config["program_name"]})

    return result


def _build_package() -> str:
    nodes = ',\n\t\t\t'.join(['"%s": "%s/%s.js"' % (f['name'],f['name'],f['name']) for f in bd.functions])

    result = tmp.render_tpl('nodered', 'package.tpl',
                            {"nodes": nodes, "module_name": bd.config["program_name"]})

    return result


def _build_dep():
    global module_dir
    module_dir = bd.config["build_path"] + '/nodered_%s' % bd.config["program_name"]
    if not os.path.isdir(module_dir):
        os.mkdir(module_dir)


def build():
    _build_dep()

    for i, f in enumerate(bd.functions):
        func_dir = module_dir + '/%s' % f['name']
        if not os.path.isdir(func_dir):
            os.mkdir(func_dir)

        html_src = _build_html(i)
        js_src = _build_js(i)

        with open(func_dir + '/%s.html' % (f['name']), "wt") as fl:
            fl.write(html_src)

        with open(func_dir + '/%s.js' % (f['name']), "wt") as fl:
            fl.write(js_src)

        shutil.copytree(bd.__work_dir__ + '/src/templates/nodered/icons', func_dir + "/icons")


    package_src = _build_package()


    with open(module_dir + '/package.json', "wt") as f:
        f.write(package_src)



