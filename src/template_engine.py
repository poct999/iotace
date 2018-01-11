from jinja2 import Environment, FileSystemLoader
import src.build_data as bd


templates_path =  bd.__src_dir__ + '/templates'


def render_tpl(module_name, tpl_name, context):
    path = templates_path + '/' + module_name
    filename = tpl_name

    return Environment(
        loader = FileSystemLoader(path or './'),
    ).get_template(filename).render(context, enumerate=enumerate, len=len)

