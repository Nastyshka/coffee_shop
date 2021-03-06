import 'dart:async';

import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'CoffeeSaleFields.dart';

class ManageMenuItem extends StatefulWidget {
  const ManageMenuItem(
      {Key? key,
      required this.name,
      required this.price,
      required this.id,
      required this.provider,
      required this.updateParentFunction})
      : super(key: key);
  final int id;
  final String name;
  final double price;
  final GSheetsAPI provider;
  final updateParentFunction;

  @override
  _ManageMenuItem createState() => _ManageMenuItem(name, price, id,
      provider: provider, updateFunction: updateParentFunction);
}

typedef Int2VoidFunc = void Function(double);

class _ManageMenuItem extends State<ManageMenuItem> {
  final _formKey = GlobalKey<FormState>();
  final GSheetsAPI provider;
  String _name = 'yy';
  double _price = 0;
  bool animated = false;
  int _id = 0;
  final VoidCallback updateFunction;

  _ManageMenuItem(String name, double price, int id,
      {required this.provider, required this.updateFunction}) {
    _name = name;
    _price = price;
    _id = id;
  }

  DateTime buttonClickTime = DateTime.now();

  bool isRedundantClick(DateTime currentTime) {
    if (buttonClickTime == null) {
      buttonClickTime = currentTime;
      return false;
    }
    if (currentTime.difference(buttonClickTime).inSeconds < 1) {
      //set this difference time in seconds
      return true;
    }

    buttonClickTime = currentTime;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameEditingController =
        TextEditingController(text: _name);
    TextEditingController priceEditingController =
        TextEditingController(text: '${this._price}');

    List<Widget> actionWidgets = <Widget>[
      ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(9),
          primary: Color(0xF90d595a),
          onPrimary: Colors.white,
        ),
        onPressed: () async {
          if (isRedundantClick(DateTime.now())) {
            print('hold on, processing');
            return;
          }

          showEditDialog(context, nameEditingController,
              priceEditingController);
        },
        child: const Icon(Icons.edit),
      ),];

    if (this._id != 2) {
      actionWidgets.add(ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.red,
          onPrimary: Colors.white,
          shape: CircleBorder(),
          padding: EdgeInsets.all(9),
        ),
        onPressed: () async {
          if (isRedundantClick(DateTime.now())) {
            print('hold on, processing');
            return;
          }
          await widget.provider.deleteItemFromMenu(_id);
          widget.updateParentFunction();
        },
        child: const Icon(Icons.delete),
      ));
    }
    return Card(
        child: Container(
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.only(left: 2, right: 7, top: 7, bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    width: 120,
                    child: Text('${this._name}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold))),
                Padding(
                    padding:
                        EdgeInsets.only(left: 39, right: 0, top: 0, bottom: 0),
                    child: Text('${this._price}???',
                        style: TextStyle(fontSize: 18))),
                // Spacer(),
                Spacer(),
                Row(children: actionWidgets),
              ],
            )));
  }

  void showEditDialog(
      BuildContext context,
      TextEditingController nameEditingController,
      TextEditingController priceEditingController) {
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
            title: Text('??????????????',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color(0xFF0d595a),
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            content: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: nameEditingController,
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '??????????',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '???????????????????? ????????';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: priceEditingController,
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: const InputDecoration(
                      border: UnderlineInputBorder(),
                      labelText: '????????',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '???????????????????? ????????';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      child: Text("????????????????"),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          widget.provider.updateMenuItem(_id, {
                            CoffeeSaleFields.name: nameEditingController.text,
                            CoffeeSaleFields.price:
                                double.parse(priceEditingController.text)
                          });
                          _formKey.currentState!.save();

                          Navigator.pop(context);
                          Timer _timer =
                              new Timer(const Duration(milliseconds: 900), () {
                            setState(() {
                              _name = nameEditingController.text;
                              _price =
                                  double.parse(priceEditingController.text);
                            });
                          });
                        }
                      },
                    )),
              ]),
            )));
  }
}
