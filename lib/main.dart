import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

const request = "https://api.hgbrasil.com/finance?format=json&key=86eb788b";

void main() async {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        hintColor: Colors.amber,
        primaryColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
          focusedBorder:
              OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
          hintStyle: TextStyle(color: Colors.amber),
        )),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  double dolar;
  double euro;

  Widget build(BuildContext context) {
    final realController = TextEditingController();
    final dolarController = TextEditingController();
    final euroController = TextEditingController();

    void _clearAll() {
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    }

    void _realChanged(String text) {
      if (text.isEmpty) {
        _clearAll();
      }
      double real = double.parse(text);
      dolarController.text = (real / dolar).toStringAsFixed(2);
      euroController.text = (real / euro).toStringAsFixed(2);
    }

    void _dolarChanged(String text) {
      if (text.isEmpty) {
        _clearAll();
      }
      double dolar = double.parse(text);
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
    }

    void _euroChanged(String text) {
      if (text.isEmpty) {
        _clearAll();
      }
      double euro = double.parse(text);
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro).toStringAsFixed(2);
    }

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: Text(
            "Conversor de Moedas",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.yellow,
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Carregando Dados",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erro ao carregar dados",
                      style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dolar = snapshot.data["USD"]["buy"];
                  euro = snapshot.data["EUR"]["buy"];
                  return SingleChildScrollView(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Icon(
                              Icons.monetization_on,
                              size: 120,
                              color: Colors.white,
                            ),
                          ),
                          Column(
                            children: [
                              buildTextField(
                                  "Reais", "R\$", realController, _realChanged),
                              Divider(),
                              buildTextField("Doláres", "USD\$",
                                  dolarController, _dolarChanged),
                              Divider(),
                              buildTextField(
                                  "Euros", "€", euroController, _euroChanged),
                              Divider(),
                            ],
                          ),
                        ],
                      ));
                }
            }
          },
        ));
  }
}

Widget buildTextField(String label, String prefix, TextEditingController c,
    Function handleChange) {
  return TextField(
    controller: c,
    keyboardType: TextInputType.number,
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.amber,
        fontSize: 18,
      ),
      border: OutlineInputBorder(),
      prefixText: "$prefix",
      prefixStyle: TextStyle(color: Colors.amber, fontSize: 18),
    ),
    onChanged: handleChange,
  );
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body)["results"]["currencies"];
}
