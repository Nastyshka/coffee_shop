import 'dart:async';

import 'package:coffee_tracker/CoffeeItem.dart';
import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:coffee_tracker/MenuManagementWidget.dart';
import 'package:coffee_tracker/MyMenuItem.dart';
import 'package:coffee_tracker/OneSale.dart';
import 'package:coffee_tracker/SalesOfTheDayWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final gProvider = GSheetsAPI();

  /// Initialize provider
  await gProvider.init();

  runApp(MyApp(provider: gProvider));
}

class MyApp extends StatelessWidget {
  GSheetsAPI provider;

  static const MaterialColor darkTeal = MaterialColor(0xFF0d595a, <int, Color>{
    50: Color(0xFFE2EBEB),
    100: Color(0xFFB6CDCE),
    200: Color(0xFF86ACAD),
    300: Color(0xFF568B8C),
    400: Color(0xFF317273),
    500: Color(0xFF0d595a),
    600: Color(0xFF0B5152),
    700: Color(0xFF094848),
    800: Color(0xFF073E3F),
    900: Color(0xFF032E2E),
  });

  MyApp({Key? key, required this.provider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Coffee',
      theme: ThemeData(
        primarySwatch: darkTeal,
        scaffoldBackgroundColor: Color(0x99EEE1B2),
      ),
      home: MyHomePage(title: 'Кава тут', provider: provider, mode: AppMode.sales),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GSheetsAPI provider;
  String title;
  AppMode mode = AppMode.menu;

  MyHomePage(
      {Key? key,
      required this.title,
      required this.provider,
      required this.mode})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  late double todayTotal = 0;
  DateTime _selectedDay = DateTime.now();

  Future<List<MyMenuItem>> get menu => getMenuData();

  Future<List<CoffeeItem>> get coffees => getDataForDay(
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));

  set coffees(Future<List<CoffeeItem>> cc) {
    coffees = cc;
  }

  late SalesOfTheDayWidget salesWidget;
  late MenuManagementWidget menuWidget;

  Future<List<MyMenuItem>> getMenuData() async {
    Future<List<MyMenuItem>> menu = widget.provider.getMenu();
    return menu;
  }

  Future<List<CoffeeItem>> getDataForDay(selectedDate) async {
    List<MyMenuItem> menu = await widget.provider.getMenu();
    List<CoffeeItem> res = <CoffeeItem>[];
    List<OneSale> sales = await widget.provider.getAggSalesData();
    Map<dynamic, OneSale> salesByDate = Map();
    if (sales != null) {
      sales.forEach((oneSale) {
        if (oneSale.saleDate.year == selectedDate.year &&
            oneSale.saleDate.month == selectedDate.month &&
            oneSale.saleDate.day == selectedDate.day) {
          salesByDate[oneSale.name] = oneSale;
        }
      });
    }
    todayTotal = 0;
    for (MyMenuItem item in menu) {
      CoffeeItem ci = CoffeeItem(item.name, item.price, 0);
      if (salesByDate[item.name] != null) {
        ci.amountSold = salesByDate[item.name]!.amountSold;
        todayTotal += ci.amountSold * item.price;
      }
      res.add(ci);
    }
    return res;
  }

  @override
  Widget build(BuildContext context) {
    getMainWidgetByMode();
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        //apply padding to all four sides
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.title),
              Padding(
                  padding:
                      EdgeInsets.only(left: 0, bottom: 0, right: 25, top: 0),
                  child: buildChangeModeButton())
            ]),
        leading: Padding(
          padding: EdgeInsets.only(left: 10, bottom: 0, right: 0, top: 0),
          child: Image.asset('assets/images/logo.png'),

        ),
      ),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: buildMainPage()),
    );
  }

  List<Widget> buildMainPage() {
    List<Widget> res = <Widget>[];
    if (widget.mode == AppMode.sales) {
      res.add(Ink(color: const Color(0xFF0d595a), child: buildDateHeaderRow()));
    } else {
      res.add(buildAddMenuButton());
    }
    res.add(Expanded(child: getMainWidgetByMode()));
    return res;
  }

  IconButton buildChangeModeButton() {
    if (widget.mode == AppMode.sales) {
      return IconButton(
        icon: Icon(Icons.construction),
        onPressed: () {
          setState(() {
            widget.mode = AppMode.menu;
          });
        },
      );
    } else {
      return IconButton(
        icon: Icon(Icons.add_business),
        onPressed: () {
          setState(() {
            widget.mode = AppMode.sales;
          });
        },
      );
    }
  }

  Widget getMainWidgetByMode() {
    if (widget.mode == AppMode.sales) {
      salesWidget = SalesOfTheDayWidget(
          coffees: coffees,
          provider: widget.provider,
          selectedDay: _selectedDay);
      return salesWidget;
    } else {
      menuWidget = MenuManagementWidget(
          menuItems: menu,
          provider: widget.provider,
          updateParentFunction: refreshMenuPage);
      return menuWidget;
    }
  }

  reloadMenuPage() {
    widget.mode = AppMode.menu;
  }

  Padding buildAddMenuButton() {
    TextEditingController nameEditingController = TextEditingController();
    TextEditingController priceEditingController = TextEditingController();
    return Padding(
        padding: EdgeInsets.only(left: 25, bottom: 0, right: 0, top: 15),
        child: FloatingActionButton.extended(
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Додати нову каву'),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                      title: const Text('Додати в меню ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: const Color(0xFF0d595a),
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      content: Form(
                        key: _formKey,
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: nameEditingController,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Назва',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Обовязкове поле';
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
                                    labelText: 'Ціна',
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Обовязкове поле';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    child: Text("Додати"),
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        widget.provider.addItemToMenu(
                                            nameEditingController.text,
                                            double.parse(
                                                priceEditingController.text));
                                        _formKey.currentState!.save();

                                        Navigator.pop(context);
                                        Timer _timer = new Timer(
                                            const Duration(milliseconds: 900),
                                            () {
                                          setState(() {
                                            widget.mode = AppMode.menu;
                                          });
                                        });
                                      }
                                    },
                                  )),
                            ]),
                      )));
            }));
  }

  Row buildDateHeaderRow() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          TextButton(
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: -1));
                });
              },
              child: Icon(Icons.navigate_before, color: Colors.white)),
          Text(DateFormat.yMd().format(_selectedDay),
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  // color: Color(0xFF0d595a)),
                  color: Colors.white)),
          TextButton(
              onPressed: () {
                setState(() {
                  _selectedDay = _selectedDay.add(const Duration(days: 1));
                });
              },
              child: Icon(
                Icons.navigate_next,
                color: Colors.white,
              )),
          Padding(
              padding: EdgeInsets.only(left: 0, bottom: 0, right: 0, top: 0),
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      _selectedDay = DateTime.now();
                    });
                  },
                  color: Colors.white,
                  icon: Icon(Icons.refresh)))
        ]);
  }

  refreshMenuPage() {
    setState(() {
      widget.mode = AppMode.menu;
    });
  }
}

enum AppMode { menu, sales }
