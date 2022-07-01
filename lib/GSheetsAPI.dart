import 'package:coffee_tracker/OneSale.dart';
import 'package:gsheets/gsheets.dart';

import 'MyMenuItem.dart';
import 'keys.dart';

class GSheetsAPI {
  static final _credentials = keys.getGcredentials();

  static final _sheetId = keys.getGsheetId();

  static Worksheet? _menuSheet;
  static Worksheet? _salesSheet;
  static Worksheet? _todaySalesSheet;

  static final _gsheets = GSheets(_credentials);

  Future init() async {
    final ss = await _gsheets.spreadsheet(_sheetId);
    _salesSheet = await _getWorkSheet(ss, title: 'sales');
    _todaySalesSheet = await _getWorkSheet(ss, title: 'salesByDay');
    _menuSheet = await _getWorkSheet(ss, title: 'menu');
  }

  Future submitSale(String name, double price, int amount) async {
    final sale = new OneSale(name, price, amount, DateTime.now());
    return _salesSheet!.values.map.appendRow(sale.toJson());
  }

  Future addItemToMenu(String newName, double newPrice) async {
    final newMenuItem = MyMenuItem(newName, newPrice);
    return _menuSheet!.values.map.appendRow(newMenuItem.toJson());
  }

  Future<List<MyMenuItem>> getMenu() async {
    final values = await _menuSheet!.values.map.allRows();
    return values!.map((value) => MyMenuItem.fromJson(value)).toList();
  }

  Future<List<OneSale>> getAggSalesData() async {
    final values = (await _todaySalesSheet!.values.map.allRows());
    return values!.map((value) => OneSale.fromJson(value)).toList();
  }

  Future<bool> deleteItemFromMenu(int index) async {
    if (_menuSheet == null) return false;
     return _menuSheet!.deleteRow(index);
  }

  Future<bool> updateMenuItem(int index, Map<String, dynamic> newValues) async {
    if (_menuSheet == null) return false;
    return _menuSheet!.values.map.insertRow(index, newValues);
  }


  Future<Worksheet> _getWorkSheet(Spreadsheet ss,
      {required String title}) async {
    return ss.worksheetByTitle(title)!;
  }
}