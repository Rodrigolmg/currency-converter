import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

const request = "https://api.hgbrasil.com/finance?format=json&key=c3824db6";

void main() async {


  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
      hintColor: Colors.amber,
      primaryColor: Colors.amberAccent
    ),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final realController = new TextEditingController();
  final dolarController = new TextEditingController();
  final eurosController = new TextEditingController();

  double dolar;
  double euro;

  void _realChanged(String text){
    if(text.isEmpty){
      dolarController.text = "";
      eurosController.text = "";
      return;
    }

    double real = double.parse(text.replaceAll(",", "."));
    dolarController.text = (real/dolar).toStringAsFixed(2).replaceAll(".", ",");
    eurosController.text = (real/euro).toStringAsFixed(2).replaceAll(".", ",");

  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      realController.text = "";
      eurosController.text = "";
      return;
    }

    double dolar = double.parse(text.replaceAll(",", "."));
    realController.text = (dolar * this.dolar).toStringAsFixed(2).replaceAll(".", ",");
    eurosController.text = (dolar * this.dolar/euro).toStringAsFixed(2).replaceAll(".", ",");

  }

  void _euroChanged(String text){
    if(text.isEmpty){
      dolarController.text = "";
      realController.text = "";
      return;
    }

    double euro = double.parse(text.replaceAll(",", "."));
    realController.text = (euro * this.euro).toStringAsFixed(2).replaceAll(".", ",");
    dolarController.text = (euro * this.euro/this.dolar).toStringAsFixed(2).replaceAll(".", ",");

  }

  void _resetField(){
    dolarController.text = "";
    realController.text = "";
    eurosController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _resetField,)
        ],
        centerTitle: true,
        title: Text("\$ Converter \$",
        style: TextStyle(
            color: Colors.black
          ),
        ),
        backgroundColor: Colors.amberAccent,
      ),
      body: FutureBuilder(
          future: getData(),
          builder: (context, snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text("Carregando dados...",
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 25.0
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
                break;
              default:
                if(snapshot.hasError){
                  return Center(
                    child: Text("Erro ao carregar dados.",
                      style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 25.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else{
                  dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                  euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          size: 125.0,
                          color: Colors.amberAccent,
                        ),
                        buildTextField("Reais", "R\$",
                            realController, _realChanged),
                        Divider(),
                        buildTextField("Dólares", "US\$",
                            dolarController, _dolarChanged),
                        Divider(),
                        buildTextField("Euros", "€",
                            eurosController, _euroChanged),
                      ],
                    ),
                  );
                }

            }
          }
      ),
    );
  }

  Future<Map> getData() async {
    http.Response response =  await http.get(request);
    return json.decode(response.body);
  }


}

Widget buildTextField(String label, String prefix,
    TextEditingController controller, Function function){
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: Colors.amberAccent
      ),
      border: OutlineInputBorder(),
      prefixText: prefix,
    ),
    style: TextStyle(
        color: Colors.amber
    ),
    onChanged: function,
    keyboardType: TextInputType.number,
  );
}
