import os
import shutil
import src.build_data as bd
import tarfile

def build():

    # bd.BUILD_DIR = bd.BUILD_DIR_BASE + "/" + bd.config["program_name"]

    # if not os.path.isdir(bd.BUILD_DIR_BASE):
    #     os.mkdir(bd.BUILD_DIR_BASE)

    build_targets = []

    if not os.path.isdir(bd.config["build_path"]):
        os.mkdir(bd.config["build_path"])


    ############## MODULES BUILD ##############

    out_list = list(bd.config["out"].keys())

    if 'duktape' in out_list:
        import src.gen.duktape as duktape
        duktape.build()

    if 'jerryscript' in out_list:
        import src.gen.jerryscript as jerryscript
        jerryscript.build()
    
    if 'civetweb' in out_list:
        import src.gen.civetweb as civetweb
        civetweb.build()
    
    if 'shell' in out_list:
        import src.gen.shell as shell
        shell.build()
    
    if 'nodejs' in out_list:
        import src.gen.nodejs as nodejs
        nodejs.build()
    
    if 'nodered' in out_list:
        import src.gen.nodered as nodered
        nodered.build()
    
    if 'express' in out_list:
        import src.gen.express as express
        express.build()

    if 'nodejs_uart_client' in out_list:
        import src.gen.nodejs_uart_client as nodejs_uart_client
        nodejs_uart_client.build()
    
    if 'nodered_uart' in out_list:
        import src.gen.nodered_uart as nodered_uart
        nodered_uart.build()
    

    # if bd.ARCHIVE:
    #     with tarfile.open(bd.BUILD_DIR_BASE+'/%s.tar'%bd.PROGRAM_NAME, "w:gz") as tar:
    #         tar.add(bd.BUILD_DIR, arcname=os.path.basename(bd.BUILD_DIR))

    #     shutil.rmtree(bd.BUILD_DIR)