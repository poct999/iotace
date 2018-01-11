import src.template_engine as tmp
import src.build_data as bd
import os
import shutil



def _build_dep():
    global nodejs_dir
    nodejs_dir = bd.config["build_path"] + '/%s' % bd.config["program_name"]
    if not os.path.isdir(nodejs_dir):
        os.mkdir(nodejs_dir)

    if not bd.config["header_path"]:
        shutil.copy(bd.config["header"], nodejs_dir)



def build():
    _build_dep()

    bd.config["out"]["nodejs"]["flags"] = list(set(bd.config["out"]["nodejs"]["flags"] + 
    ["-DNO_SSL", "-DUSE_SSL_DH=1", "-Wall"]))

    bd.config["out"]["nodejs"]["libs"] = list(set(bd.config["out"]["nodejs"]["libs"] + 
    ["-lpthread", "-ldl", "-lcrypto", "-lssl", "-lm"]))

    bd.config["out"]["nodejs"]["source"].append(bd.config["program_name"] + ".cpp")
    

    main = tmp.render_tpl('nodejs', 'main.tpl', {"functions": bd.functions, "module_name": bd.config["program_name"]})

    binding_gyp = tmp.render_tpl('nodejs', 'binding_gyp.tpl', {
        "module_name": bd.config["program_name"],
        "sources": ','.join(map(lambda f: "'" + f + "'", bd.config["out"]["nodejs"]["source"])),
        "includes": ','.join(map(lambda f: "'" + f[2:] + "'" if f[:2] == '-I' else "'" + f + "'", 
            bd.config["out"]["nodejs"]["include"])),
        "flags": ','.join(map(lambda f: "'" + f + "'", bd.config["out"]["nodejs"]["flags"])),
        "libs": ','.join(map(lambda f: "'" + f + "'", bd.config["out"]["nodejs"]["libs"]))
    })

    package = tmp.render_tpl('nodejs', 'package.tpl', {"module_name": bd.config["program_name"]})

    main_js = tmp.render_tpl('nodejs', 'main_js.tpl', {"functions": bd.functions, "module_name": bd.config["program_name"]})

    with open(nodejs_dir + '/%s.cpp' % (bd.config["program_name"]), "wt") as f:
        f.write(main)

    with open(nodejs_dir + '/%s.js' % (bd.config["program_name"]), "wt") as f:
        f.write(main_js)

    with open(nodejs_dir + '/binding.gyp', "wt") as f:
        f.write(binding_gyp)

    with open(nodejs_dir + '/package.json', "wt") as f:
        f.write(package)
