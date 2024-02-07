import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart/async.dart';
import 'dart:convert';

const request = 'https://api.hgbrasil.com/finance?key=[coloque sua chave aqui]';

void main() async {
  runApp(MaterialApp(
    showSemanticsDebugger: false,
    home: const Home(),
    theme: ThemeData(hintColor: Colors.amber, primaryColor: Colors.indigo),
  ));
}

Future<Map> getData() async {
  Uri uri = Uri.parse(request);
  http.Response response = await http.get(uri);

  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  void _clearAll() {
    realController.clear();
    dolarController.clear();
    euroController.clear();
  }

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double real = double.tryParse(text) ??
        0.0; // Tente analisar o texto como double, se falhar, use 0.0
    String dolarText = (real / dolar!).toStringAsFixed(2);
    String euroText = (real / euro!).toStringAsFixed(2);

    if (dolarController.text != dolarText) {
      dolarController.text = dolarText;
    }
    if (euroController.text != euroText) {
      euroController.text = euroText;
    }
  }

  void _dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dolar = double.tryParse(text) ?? 0.0;
    String realText = (dolar * this.dolar!).toStringAsFixed(2);
    String euroText = (dolar * this.dolar! / euro!).toStringAsFixed(2);

    if (realController.text != realText) {
      realController.text = realText;
    }
    if (euroController.text != euroText) {
      euroController.text = euroText;
    }
  }

  void _euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double euro = double.tryParse(text) ?? 0.0;
    String realText = (euro * this.euro!).toStringAsFixed(2);
    String dolarText = (euro * this.euro! / dolar!).toStringAsFixed(2);

    if (realController.text != realText) {
      realController.text = realText;
    }
    if (dolarController.text != dolarText) {
      dolarController.text = dolarText;
    }
  }

  double? dolar;
  double? euro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "Conversor de moedas",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const Center(
                child: Text(
                  "Carregando Dados...",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
              );
            default:
              if (snapshot.hasError) {
                return const Center(
                  child: Text(
                    "Erro ao carregar dados",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                );
              } else {
                dolar = snapshot.data?["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data?["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(Icons.monetization_on,
                          size: 150, color: Colors.amber),
                      buildTextField(
                          "Reais", "R\$ ", realController, _realChanged),
                      const Divider(),
                      buildTextField(
                          "Dolar", "US\$ ", dolarController, _dolarChanged),
                      const Divider(),
                      buildTextField(
                          "Euro", "€ ", euroController, _euroChanged),
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }

  Widget buildTextField(String label, String prefix,
      TextEditingController controller, void Function(String) onChanged) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.amber,
          fontSize: 25,
        ),
        border: const OutlineInputBorder(),
        prefixText: prefix,
      ),
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
