import 'dart:convert';

import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

class HomeConver extends StatefulWidget {
  const HomeConver({Key? key}) : super(key: key);

  @override
  State<HomeConver> createState() => _HomeConverState();
}

class _HomeConverState extends State<HomeConver> {
  final realControl = TextEditingController();
  final dolarControl = TextEditingController();
  final euroControl = TextEditingController();
  final btcControl = TextEditingController();

  final _moedas = ['REAL','DOLAR','EURO','BTC'];
  var _itemSelecionadoUm;
  var _itemSelecionadoDois;

  double dolar = 0;
  double euro = 0;
  double btc = 0;

  @override
  void dispose() {
    realControl.dispose();
    dolarControl.dispose();
    euroControl.dispose();
    btcControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Conversor de Moedas'),
        ),
        body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            if (!snapshot.hasError) {
              if (snapshot.connectionState == ConnectionState.done) {
                dolar = double.parse(snapshot.data!['USDBRL']['bid']);
                euro = double.parse(snapshot.data!['EURBRL']['bid']);
                btc = double.parse(snapshot.data!['BTCBRL']['bid']);
                // dolar = snapshot.data!['USD']['buy'];
                // euro = snapshot.data!['EUR']['buy'];
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Icon(
                        Icons.monetization_on_outlined,
                        size: 120,
                      ),

                      const SizedBox(
                        height: 30,
                      ),

                      Row(
                        children: <Widget>[ 
                          Expanded(child: 
                            verificaItemSelecionado((_itemSelecionadoUm != null) ? _itemSelecionadoUm : _itemSelecionadoUm = "REAL"),
                          ),
                          Container(
                            height: 59,
                            decoration: BoxDecoration(
                              border: Border.all (
                                width: 1.5, 
                                color: const Color.fromARGB(255, 185, 185, 185)
                                ),
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Selecione..."),
                                value: (_itemSelecionadoUm != null) ? _itemSelecionadoUm : _itemSelecionadoUm = "REAL",
                                onChanged: (String? value) {
                                  mudaStateUm(value);
                                },
                                items : _moedas.map((String dropDownStringItem) =>  DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  )
                                ).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(
                        height: 10,
                      ),

                      IconButton(
                        onPressed: () => {
                          inverterCampos()
                        }, 
                        icon: const Icon(Icons.change_circle_rounded),
                        iconSize: 50,
                      ),
                      

                      const SizedBox(
                        height: 10,
                      ),

                      Row(
                        children: <Widget>[ 
                          Expanded(child: 
                            verificaItemSelecionado((_itemSelecionadoDois != null) ? _itemSelecionadoDois : _itemSelecionadoDois = "REAL"),
                          ),
                          Container(
                            height: 59,
                            decoration: BoxDecoration(
                              border: Border.all (
                                width: 1.5, 
                                color: const Color.fromARGB(255, 185, 185, 185)
                                ),
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(6), bottomRight: Radius.circular(6)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                hint: const Text("Selecione..."),
                                value: (_itemSelecionadoDois != null) ? _itemSelecionadoDois : _itemSelecionadoDois = "REAL",
                                onChanged: (String? value) {
                                  mudaStateDois(value);
                                },
                                items : _moedas.map((String dropDownStringItem) =>  DropdownMenuItem<String>(
                                    value: dropDownStringItem,
                                    child: Text(dropDownStringItem),
                                  )
                                ).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              } else {
                return waitingIndicator();
              }
            } else {
              return waitingIndicator();
            }
          },
        ));
  }

  void mudaStateUm(String? value) {
    return setState(() {
      _itemSelecionadoUm = value!;                  
    });
  }

  void mudaStateDois(String? value) {
    return setState(() {
      _itemSelecionadoDois = value!;                  
    });
  }

  void inverterCampos() {
    var itemUm = _itemSelecionadoUm;    
    var itemDois = _itemSelecionadoDois;

    mudaStateUm(itemDois);
    mudaStateDois(itemUm);
    
  }

  TextField verificaItemSelecionado(String _itemSelecionado) {

    if (_itemSelecionado == "DOLAR"){
      return currencyTextField('Dolares', 'US\$ ', dolarControl, _convertDolar);
    } else if (_itemSelecionado == "EURO") {
      return currencyTextField('Euros', '€ ', euroControl, _convertEuro);
    } else if (_itemSelecionado == "BTC") {
      return currencyTextField('Btc', 'B', btcControl, _convertBtc);
    } else {
      return currencyTextField('reais ', 'R\$ ', realControl, _convertReal);
    }
  }

  TextField currencyTextField(String label, String prefixText,
                  TextEditingController controller, Function f) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(6), bottomLeft: Radius.circular(6))
        ),
        
        prefixText: prefixText,
      ),
      onChanged: (value) => f(value),
      keyboardType: TextInputType.number,
    );
  }

  Center waitingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  void _convertReal(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double real = double.parse(text);
    dolarControl.text = (real / dolar).toStringAsFixed(2);
    euroControl.text = (real / euro).toStringAsFixed(2);
    btcControl.text = (real / btc).toStringAsFixed(2);
  }

  void _convertDolar(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double dolar = double.parse(text);
    realControl.text = (this.dolar * dolar).toStringAsFixed(2);
    euroControl.text = ((this.dolar * dolar) / euro).toStringAsFixed(2);
    btcControl.text = ((this.dolar * dolar) / btc).toStringAsFixed(2);
  }

  void _convertEuro(String text) {
    if (text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double euro = double.parse(text);
    realControl.text = (this.euro * euro).toStringAsFixed(2);
    dolarControl.text = ((this.euro * euro) / dolar).toStringAsFixed(2);
    btcControl.text = ((this.euro * euro) / btc).toStringAsFixed(2);
  }

  void _convertBtc(String text) {
    if(text.trim().isEmpty) {
      _clearFields();
      return;
    }

    double btc = double.parse(text);
    realControl.text = (this.btc * btc).toStringAsFixed(2);
    dolarControl.text = ((this.btc * btc) / dolar).toStringAsFixed(2);
    euroControl.text = ((this.btc * btc) / dolar).toStringAsFixed(2);
  }

  void _clearFields() {
    realControl.clear();
    dolarControl.clear();
    euroControl.clear();
    btcControl.clear();
  }
}

Future<Map> getData() async {
  //* ENDEREÇO DA API NOVA
  //* https://docs.awesomeapi.com.br/api-de-moedas

  // const requestApi =
  //     "https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL";
  // var response = await http.get(Uri.parse(requestApi));
  // return jsonDecode(response.body);

  // json manual para teste em caso de
  // problema com a conexão http
   var response = 
   { 
    "USDBRL": {
      "code": "USD",
      "codein": "BRL",
      "name": "Dólar Americano/Real Brasileiro",
      "high": "5.083",
      "low": "5.0342",
      "varBid": "0.029",
      "pctChange": "0.58",
      "bid": "5.0624",
      "ask": "5.0635",
      "timestamp": "1680801158",
      "create_date": "2023-04-06 14:12:38"
    },
      "EURBRL": {
      "code": "EUR",
      "codein": "BRL",
      "name": "Euro/Real Brasileiro",
      "high": "5.5405",
      "low": "5.4798",
      "varBid": "0.0444",
      "pctChange": "0.81",
      "bid": "5.5337",
      "ask": "5.5363",
      "timestamp": "1680801158",
      "create_date": "2023-04-06 14:12:38"
    },
      "BTCBRL": {
      "code": "BTC",
      "codein": "BRL",
      "name": "Bitcoin/Real Brasileiro",
      "high": "143921",
      "low": "141346",
      "varBid": "829",
      "pctChange": "0.58",
      "bid": "142945",
      "ask": "142945",
      "timestamp": "1680800867",
      "create_date": "2023-04-06 14:07:47"
    }
  };

  return jsonDecode(jsonEncode(response));

}
