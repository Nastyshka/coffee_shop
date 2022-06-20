import 'package:coffee_tracker/CoffeeItem.dart';
import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:coffee_tracker/OneSale.dart';
import 'package:coffee_tracker/SalesOfTheDayWidget.dart';
import 'package:flutter/material.dart';
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
      home: MyHomePage(title: 'Рахувальник Кави', provider: provider),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final GSheetsAPI provider;
  String title;

  MyHomePage({Key? key, required this.title, required this.provider})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late double todayTotal = 0;
  DateTime _selectedDay = DateTime.now();

  Future<List<CoffeeItem>> get coffees => getDataForDay(
      DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day));

  set coffees(Future<List<CoffeeItem>> cc) {
    coffees = cc;
  }

  late SalesOfTheDayWidget wid;

  Future<List<CoffeeItem>> getDataForDay(selectedDate) async {
    List<CoffeeItem> menu = await widget.provider.getMenu();
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
    for (CoffeeItem item in menu) {
      if (salesByDate[item.name] != null) {
        item.amountSold = salesByDate[item.name]!.amountSold;
        todayTotal += item.amountSold * item.price;
      }
    }
    return menu;
  }

  @override
  Widget build(BuildContext context) {
    wid = SalesOfTheDayWidget(
        coffees: coffees, provider: widget.provider, selectedDay: _selectedDay);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      appBar: AppBar(
        //apply padding to all four sides
        title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(widget.title),
            ]),
        leading: Padding(
          padding: EdgeInsets.only(left: 10, bottom: 0, right: 0, top: 0),
          child: Image.asset('assets/images/logo.png'),
        ),
      ),
      body: Column(children: <Widget>[
        Ink(color: const Color(0xFF0d595a), child: buildDateHeaderRow()),
        Expanded(child: wid),
      ]),
    );
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
        ]);
  }
}
