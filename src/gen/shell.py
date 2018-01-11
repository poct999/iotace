import src.template_engine as tmp
import src.build_data as bd
import os
import shutil

def _build_dep():
    if not os.path.isdir(bd.config["build_path"] + '/shell'):
        os.mkdir(bd.config["build_path"] + '/shell')

def build():
    _build_dep()

    out_list = list(bd.config["out"].keys())

    with open(bd.config["out"]["shell"]["target"]+'/shell.c', "rt") as f:
        target_shell = f.read()

    shell = tmp.render_tpl('shell', 'shell.tpl', {"target_shell": target_shell, 
        "out_list": out_list})

    with open(bd.config["build_path"] + '/shell/shell.c', "wt") as f:
        f.write(shell)

    if bd.config["out"]["shell"]["with_app"]:
        bd.config["out"]["shell"]["flags"] = list(set(bd.config["out"]["shell"]["flags"] + 
            ["-DNO_SSL", "-std=c99", "-DUSE_SSL_DH=1", "-Wall"]))
        bd.config["out"]["shell"]["libs"] = list(set(bd.config["out"]["shell"]["libs"] + 
            ["-lpthread", "-ldl", "-lcrypto", "-lssl", "-lm"]))
        
        
        if 'jerryscript' in out_list:
            bd.config["out"]["shell"]["source"].append('jerryscript/%s_jerryscript.c' % bd.config["program_name"])

            bd.config["out"]["shell"]["include"].append('-I./jerryscript/')


        if 'duktape' in out_list:
            bd.config["out"]["shell"]["source"].append('duktape/duktape.c')
            bd.config["out"]["shell"]["source"].append('duktape/%s_duktape.c' % bd.config["program_name"])

            bd.config["out"]["shell"]["include"].append('-I./duktape/')


        if 'civetweb' in out_list:
            bd.config["out"]["shell"]["source"].append('civetweb/civetweb.c')
            bd.config["out"]["shell"]["source"].append('civetweb/%s_civetweb.c' % bd.config["program_name"])
            
            bd.config["out"]["shell"]["include"].append('-I./civetweb/')
        
        
        bd.config["out"]["shell"]["source"].append('shell/shell.c')


        if not bd.config["header_path"]:
            shutil.copy(bd.config["header"], bd.config["build_path"])
            bd.config["out"]["shell"]["include"].append('-I./')

        makefile = tmp.render_tpl('shell', 'makefile.tpl', {"makefile":{
           "source": ' '.join(bd.config["out"]["shell"]["source"]),
            "include": ' '.join(bd.config["out"]["shell"]["include"]),
            "flags": ' '.join(bd.config["out"]["shell"]["flags"]),
            "libs": ' '.join(bd.config["out"]["shell"]["libs"])
        },
             "program_name": bd.config["program_name"]})
        main = tmp.render_tpl('shell', 'main.tpl', {"out_list": out_list})

        with open(bd.config["build_path"] + '/Makefile', "wt") as f:
            f.write(makefile)

        with open(bd.config["build_path"] + '/%s.c' % bd.config["program_name"], "wt") as f:
            f.write(main)

       

