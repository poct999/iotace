<html>
<head>
    <script>
        function clickFunc(el) {
            document.getElementById('method').value = el.title;
            document.getElementById('params').value = el.name;
            document.getElementById('params').focus();
        }
        window.onload = function() {
            document.getElementById('params').focus();
        };
    </script>
    <style>
        body
        {
            text-align: center;
        }

        #main
        {
            text-align: center;
            width: 700px;
            margin: 0px auto;
            height:auto;
            font: normal bold "Times New Roman", Times, serif;
        }

        .result {
            margin: 20 auto 0 auto;
            font-size: 13px;
            font-weight: bold;
            font-family: courier;
            width: 470px;
        }

        hr
        {
            margin-top: 20px;
            margin-bottom: 20px;
            width: 450px;
        }

        td
        {
            vertical-align: top;
        }

        form
        {
            width: 700px;
            text-align: center;
            margin:15px auto;
        }
        h2
        {
            font-size: 32px;
            margin: 40px auto;
            color: #404040;
        }

        input[type="submit"]:hover
        {
            background-color:  rgba(38,51,56,0.9);
        }

        input[type="submit"]
        {
            display: inline-block;
            box-sizing: content-box;
            cursor: pointer;
            padding: 34px 35px;
            border: 1px solid rgba(0,0,0,0.2);
            margin: 6px;
            border-radius: 3px;
            font: normal 16px/normal "Times New Roman", Times, serif;
            color: rgba(255,255,255,0.9);
            background: rgba(38,51,56,1);
            box-shadow: 2px 2px 2px 0 rgba(0,0,0,0.2);
            text-shadow: -1px -1px 0 rgba(15,73,168,0.66);
        }

        input[type="text"]
        {
            margin: 5px 0px;
            display: inline-block;
            width: 400px;
            outline:none;
            padding: 10px 20px;
            border: 1px solid #b7b7b7;
            border-radius: 3px;
            font: normal 16px/normal "Times New Roman", Times, serif;
            color: rgba(27,29,30,1);
            background: rgba(252,252,252,1);
            box-shadow: 2px 2px 2px 0 rgba(0,0,0,0.2) inset;
            text-shadow: 1px 1px 0 rgba(255,255,255,0.66) ;
        }

        a
        {
            display: inline-block;
            padding: 0;
            margin: 3px 0px;
            color: #316EC4;
            text-decoration: none;
        }

        a:hover
        {
            color: blue;
        }

    </style>
</head>
<body>
    <div id="main">
        {% raw %}
        <h2>Welcome to IoTAce!</h2>
        <form action="" method="POST">
            <div>
                <div style="display: inline-block;">
                    <div>
                        <input autocomplete="off" type="text" value='{{ req.body.method }}' placeholder="Method" name="method" id="method">
                    </div>
                    <div>
                        <input autocomplete="off" type="text" value='{{ req.body.params }}' placeholder="Parameters" name="params" id="params">
                    </div>
                </div>
                <div style="display: inline-block; vertical-align: top;">
                    <input type="submit" value="Run">
                </div>
            </div>
            <input name = "jsonrpc" value = "2.0" type="hidden">
            <input name = "id" value = "1" type="hidden">
        </form>
        <table class = "result">
            <tr style="color: #316EC4">
                <td width = "60">Method:</td>
                <td> {{ req.body.method }} </td>
            </tr>
            <div id="result_block">


                {% if error %}
                <tr style="color: #DA2848">
                    <td width = "60">Result:</td>
                    <td>{{ data }}</td>
                </tr>
                {% else %}
                <tr style="color: #549F34">
                    <td width = "60">Result:
                    </td>
                    <td>{{ data }}</td>
                </tr>
                {% endif %}

            </div>
        </table>
        {% endraw %}
        <hr>
    </div>

    {% for f in functions %}
    <a href="#" name="[{{ f.input_unknown_args }}]" title="{{ f.name }}" onClick="clickFunc(this);"><span style="color: grey">{{ f.return_type_full }}</span> {{ f.name }}<span style="color: grey">({{ f.input_args }})</span></a>
    <br/>
    {% endfor %}


</body>
</html>
