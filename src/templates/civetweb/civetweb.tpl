#include "civetweb.h"
#include <string.h>

int iotace_js_eval(char*, char*, unsigned int);

void civetweb_add_discr(struct mg_connection *conn)
{
    {% for f in functions %}
    mg_printf(conn, "<a href=\"#\" name=\"[{{ f.input_unknown_args }}]\" title=\"{{ f.name }}\" onClick=\"clickFunc(this);\"><span style=\"color: grey\">{{ f.return_type_full }}</span> {{ f.name }}<span style=\"color: grey\">({{ f.input_args }})</span></a><br/>");
    {% endfor %}
}

void gen_jsonrpc(char* result_string, char* jsonrpc, char* result, char* id)
{
    sprintf(result_string, "{\"jsonrpc\":\"%s\",\"result\":%s,\"id\":%s}", jsonrpc, result, id);
}

void gen_jsonrpc_error(char* result_string, char* jsonrpc, char* error_code, char* error_message, char* id)
{
    sprintf(result_string, "{\"jsonrpc\":\"%s\",\"error\":{\"code\":%s,\"message\":\"%s\"},\"id\":%s}",
            jsonrpc, error_code, error_message, id);
}

int API_V1(struct mg_connection *conn, void *cbdata, char* result, char* jsonrpc, char* method, char* params, char* id)
{
    char post_data[10 * 1024];
    int post_data_len = mg_read(conn, post_data, sizeof(post_data));

    mg_get_var(post_data, post_data_len, "method", method, 2048);
    mg_get_var(post_data, post_data_len, "params", params, 2048);
    mg_get_var(post_data, post_data_len, "jsonrpc", jsonrpc, 100);
    mg_get_var(post_data, post_data_len, "id", id, 100);


    char arguments[200] = {0};
    if (strcmp(jsonrpc, "2.0") || strlen(method) == 0 || strlen(id) == 0) {
        gen_jsonrpc_error(result, "2.0", "-32700", "Parse error", "null");
        return 1;
    }
    {% for f in functions %}
    else if (!strcmp(method, "{{ f.name }}"))
        strcpy(arguments, "[{%- for p in f.in_p -%}args[\"{{ p.name }}\"],{%- endfor -%}]");
    {% endfor %}
    else
        strcpy(arguments, "[]");

    char js_cmd[2100] = {0};


    sprintf(js_cmd, "args = JSON.parse('%s'); if (Array.isArray(args)) result = %s.apply(this, args); else result = %s.apply(this,%s); JSON.stringify(result);", params, method, method, arguments);

    char tmp[1500] = {0};
    
    if (iotace_js_eval(js_cmd, tmp, 1500) != 0) {
        gen_jsonrpc_error(result, "2.0", "-32600", tmp, id);
        return 2;
    } else {
        gen_jsonrpc(result, "2.0", tmp, id);
        return 0;
    }
}

int APIHandlerV1(struct mg_connection *conn, void *cbdata)
{
    char jsonrpc[100] = {0};
    char id[100] = {0};
    char method[2048] = {0};
    char params[2048] = {0};
    char result[2048] = {0};
    API_V1(conn, cbdata, result, jsonrpc, method, params, id);

    mg_printf(conn,"HTTP/1.1 200 OK\r\nContent-Type: json\r\nConnection: close\r\n\r\n");
    mg_printf(conn, "%s", result);

    return 1;
}

int HomeHandler(struct mg_connection *conn, void *cbdata)
{
    char jsonrpc[100] = {0};
    char id[100] = {0};
    char method[2048] = {0};
    char params[2048] = {0};
    char result[2048] = {0};
    int API_res = API_V1(conn, cbdata, result, jsonrpc, method, params, id);

    mg_printf(conn,"HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nConnection: close\r\n\r\n");
    mg_printf(conn, "<html>");
    mg_printf(conn, "<head>");
    mg_printf(conn, "<script>");
    mg_printf(conn, "function clickFunc(el) {document.getElementById('method').value = el.title;document.getElementById('params').value = el.name;document.getElementById('params').focus();}");
    mg_printf(conn, "window.onload = function() {document.getElementById('params').focus();}");
    mg_printf(conn, "</script>");
    mg_printf(conn, "<style>");
    mg_printf(conn, "body{text-align: center;}");
    mg_printf(conn, "#main{text-align: center;width: 700px;margin: 0px auto;height:auto;font: normal bold \"Times New Roman\", Times, serif;}");
    mg_printf(conn, ".result {margin: 20 auto 0 auto;font-size: 13px;font-weight: bold;font-family: courier;width: 470px;}");
    mg_printf(conn, "hr {margin-top: 20px;margin-bottom: 20px;width: 450px;}");
    mg_printf(conn, "td {vertical-align: top;}");
    mg_printf(conn, "form {width: 700px;text-align: center;margin:15px auto;}");
    mg_printf(conn, "h2 {font-size: 32px;margin: 40px auto;color: #404040;}");
    mg_printf(conn, "input[type=\"submit\"]:hover {background-color:  rgba(38,51,56,0.9);}");
    mg_printf(conn, "input[type=\"submit\"] {display: inline-block;box-sizing: content-box;cursor: pointer;padding: 34px 35px; border: 1px solid rgba(0,0,0,0.2);");
    mg_printf(conn, "margin: 6px; border-radius: 3px;font: normal 16px/normal \"Times New Roman\", Times, serif;color: rgba(255,255,255,0.9);background: rgba(38,51,56,1);");
    mg_printf(conn, "box-shadow: 2px 2px 2px 0 rgba(0,0,0,0.2);text-shadow: -1px -1px 0 rgba(15,73,168,0.66);}");
    mg_printf(conn, "input[type=\"text\"] {	margin: 5px 0px; display: inline-block;width: 400px;outline:none;padding: 10px 20px;border: 1px solid #b7b7b7;border-radius: 3px;");
    mg_printf(conn, "font: normal 16px/normal \"Times New Roman\", Times, serif;color: rgba(27,29,30,1);background: rgba(252,252,252,1);");
    mg_printf(conn, "box-shadow: 2px 2px 2px 0 rgba(0,0,0,0.2) inset;text-shadow: 1px 1px 0 rgba(255,255,255,0.66) ;}");
    mg_printf(conn, "a {display: inline-block;padding: 0;margin: 3px 0px;color: #316EC4;text-decoration: none;}");
    mg_printf(conn, "a:hover {color: blue;}");
    mg_printf(conn, "</style>");
	mg_printf(conn, "</head>");

    mg_printf(conn, "<body>");
    mg_printf(conn, "<div id=\"main\">");
    mg_printf(conn, "<h2>Welcome to IoTAce!</h2>");
    mg_printf(conn, "<form action=\"\" method=\"POST\">");
    mg_printf(conn, "<div><div style=\"display: inline-block;\"><div>");
    mg_printf(conn, "<input autocomplete=\"off\" type=\"text\" value='%s' placeholder=\"Method\" name=\"method\" id=\"method\">", method);
    mg_printf(conn, "</div><div>");
    mg_printf(conn, "<input autocomplete=\"off\" type=\"text\" value='%s' placeholder=\"Parameters\" name=\"params\" id=\"params\">", params);
    mg_printf(conn, "</div></div> <div style=\"display: inline-block; vertical-align: top;\">");
    mg_printf(conn, "<input type=\"submit\" value=\"Run\"> ");
    mg_printf(conn, "</div></div>");
    mg_printf(conn, "<input name = \"jsonrpc\" value = \"2.0\" type=\"hidden\">");
    mg_printf(conn, "<input name = \"id\" value = \"1\" type=\"hidden\"> </form>");


    mg_printf(conn, "<table class = \"result\">");
    mg_printf(conn, "<tr style=\"color: #316EC4\"><td width = \"60\">Method:</td><td>%s %s</td></tr>", method, params);

    if (API_res) {
	    mg_printf(conn, "<tr style=\"color: #DA2848\"><td width = \"60\">Result:</td><td>%s</td></tr>", result);
    }else{
        mg_printf(conn, "<tr style=\"color: #549F34\"><td width = \"60\">Result:</td><td>%s</td></tr>", result);
    }

	mg_printf(conn, "</table>");
    mg_printf(conn, "<hr>");
    mg_printf(conn, "</div>");

    civetweb_add_discr(conn);

    mg_printf(conn, "</body></html>\n");

    return 1;
}


struct mg_context *cw_ctx;
int iotace_rest_init()
{
    const char *options[] = {
        "listening_ports",
        "8888",
        "request_timeout_ms",
        "10000",
    0};
    struct mg_callbacks callbacks;

    memset(&callbacks, 0, sizeof(callbacks));

    cw_ctx = mg_start(&callbacks, 0, options);

    mg_set_request_handler(cw_ctx, "/", HomeHandler, 0);
    mg_set_request_handler(cw_ctx, "/api/v1", APIHandlerV1, 0);

    printf("Server listening on port 8888\n");

    return 1;
}

int iotace_rest_uninit()
{
    mg_stop(cw_ctx);
    return 1;
}