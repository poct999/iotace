'''
IoTace
'''

import argparse
import src.build_data as bd
import src.generator as gen
import src.parser as pars
import src.notice as notice
import src.config_parser as config_parser
import src.decorate_params as decor


def start():
    try:
        pars.get_build_data()
        pars.check_decl(bd.functions)
        decor.__change_data_for_render()

    except Exception:
        notice.add_error_by_id_and_exit(7)

    gen.build()


if __name__ == "__main__":
    ap = argparse.ArgumentParser(
        description="""
    EXAMPLE:
    ./iotace.py --config="config/nodered.json"
    """,
        prog='IoTace'
    )
    
    ap.add_argument("--config", required=True, help="path to config file")
    args = vars(ap.parse_args())
    config_parser.parse(args["config"])

    start()
