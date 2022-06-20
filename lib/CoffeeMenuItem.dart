import 'dart:async';

import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:flutter/material.dart';

class CoffeeMenuItem extends StatefulWidget {
  const CoffeeMenuItem(
      {Key? key,
      required this.name,
      required this.price,
      required this.amountSold,
      required this.editable,
      required this.provider,
      required this.updateFunction})
      : super(key: key);
  final String name;
  final double price;
  final int amountSold;
  final GSheetsAPI provider;
  final updateFunction;
  final editable;

  @override
  _MenuItem createState() => _MenuItem(name, price, amountSold, editable,
      provider: provider, updateFunction: updateFunction);
}

typedef Int2VoidFunc = void Function(double);

class _MenuItem extends State<CoffeeMenuItem> {
  final GSheetsAPI provider;
  int _amountSold = 0;
  String _name = 'yy';
  double _price = 0;
  bool animated = false;
  bool _editable = false;
  final ValueSetter<double> updateFunction;

  _MenuItem(String name, double price, int amountSold, bool editable,
      {required this.provider, required this.updateFunction}) {
    _name = name;
    _price = price;
    _amountSold = amountSold;
    _editable = editable;
  }

  void _increment() {
    widget.updateFunction(_price);
    setState(() {
      animated = true;
      _amountSold++;
      Timer(Duration(milliseconds: 400), () {
        setState(() {
          animated = false;
        });
      });
    });
  }

  void showIncMessage() {}

  void showDecMessage() {}

  void _decrement() {
    widget.updateFunction(-1 * _price);
    setState(() {
      _amountSold--;
      animated = true;
      Timer(Duration(milliseconds: 400), () {
        setState(() {
          animated = false;
        });
      });
    });
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
    return Card(
        child: Container(
            margin: EdgeInsets.all(4.0),
            padding: EdgeInsets.only(left: 2, right: 7, top: 7, bottom: 7),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(children: <Widget>[
                  Container(
                      width: 120,
                      child: Text('${this._name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold))),
                  Text('${this._price}₴')
                ]),
                // Spacer(),
                Spacer(),
                Padding(
                  padding:
                      EdgeInsets.only(left: 10, bottom: 0, right: 33, top: 0),
                  //apply padding to all four sides
                  child: AnimatedDefaultTextStyle(
                    child: Text(' $_amountSold'),
                    style: animated
                        ? TextStyle(
                            fontSize: 35,
                            color: Colors.grey,
                          )
                        : TextStyle(
                            color: Colors.grey,
                            fontSize: 23,
                          ),
                    duration: Duration(milliseconds: 200),
                    curve: Curves.bounceInOut,
                  ),
                ),
                _editable
                    ? Row(children: <Widget>[
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
                            bool res = await widget.provider
                                .submitSale(this._name, this._price, 1);
                            if (res) {
                              _increment();
                              showIncMessage();
                            }
                          },
                          child: const Icon(Icons.add),
                        ),
                        ElevatedButton(
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
                            _decrement();
                            await widget.provider
                                .submitSale(this._name, this._price, -1);
                            showDecMessage();
                          },
                          child: const Icon(Icons.remove),
                        ),
                      ])
                    : Row(children: <Widget>[]),
              ],
            )));
  }
}
