import 'package:coffee_tracker/CoffeeSaleFields.dart';
import 'package:coffee_tracker/OneSale.dart';
import 'package:coffee_tracker/CoffeeItem.dart';
import 'package:gsheets/gsheets.dart';

class GSheetsAPI {
  static const _credentials = r'''{
  "type": "service_account",
  "project_id": "sheety-test-247715",
  "private_key_id": "4ce47279d0d012973ea0490911462aa66769fae3",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3G50o/jNVrwk6\nN2gFBVee5N3S/Yue8tfSEbgjOkwtladANNCaz0EKPqeudUoFDNSm/SC0K53kWMlV\ngQn62LTeZOqi5ZOccDaAkqsW2vaXwSdC0lUhA4VEdTAcUrMwPmFBGJgaXQoOFXVG\nOmwfddC5+OZ7DDzIbQDqWXZ+A9fqbazBfuvAjcGNluvF8/z03pdzulwAS9u1m+A2\ntPjW0cy2c7B6DG84cSNFuM3p82g3K4ivYjD/Wxoup3Jzsz48YoGJe3QsDmfxGudT\n8KKY+87jhqIxwxX22IrZyClg/7p1GlbXuH56Pf878ksMG+8WQhFctIjXreeJMkhN\nCjMlZmrpAgMBAAECggEAALdu0mIz8E6bVYMck6LJV0hhE6zqkumzcsGJ6WMLuS9x\nXGYrLU8+O3R9OpNqrFxNc5BWGbe5z32R9HUpGqD7tzWTo1AiQgiAjBkBf/kazINP\nhyVJ0D43vf8hPAZ4/Ulh3yEh95Nxi+vP/fanUD8JUlr7yD48ZCfktaYPOW/EKek4\nLp1gXtA49Gb4xwQ0fRRJNbiciO9OpWlpGE0sN7xPEqEyWW+KoFKNbRi4TU7Tao7s\nHZPpRIwIvFpdGIcWjjUT/n2vXnJ2ZeKjjQMOVN/BMo1H7CauCkfUh/rVqw2giVtg\nOTNCIy47Zu7Q/PzAGBNmrPsbkOeQkfOTGrnnQ90uAQKBgQDcStN91bjzbkZUBg7y\nqdx8KaWrfoQ+46d5uurL3YXQYZJLckgA3Q/4P9/2mIoS5e9Z6TtO+SyN/UXb9Epj\nQG4LGOM6jifgWBREHanm44libj8LWoKiYo+VQcGkZfy8w42vmle9UaKNZKCZaDfd\nycslakmZhOIRq+/3ir2eoNH2AQKBgQDUycutnQtbKWlzs28+/2kiD9J3+oNct0d0\nCfnSOlywZ2lBdi3DjHzpUyVY5DqmqZ0AkKM7PVKolpm/MzyvRFu+M1vD3LTl/2Oe\nR0Oai+S7GBfTTPBSAyICTYBclOYz53UIKCR7rWqoXsZbCIOIt5G/RRx8mZSVq96Q\nLY7DFXWE6QKBgQDJrVtoJaU4f+m0/QLsWGQ56+r3UVGDPepSgLR6xai/eMR1e/+9\ngqUfMmM5ILevy4BQgT1B9M88gvZVA5aivRbB5BwLvJ93PUv4fGvSrNdXHPVs0IUu\nYytuiw/cEV7L9gAeFyBie31lEw4QxB/5Vcg8zczp1oUdhpqftw4YTsVKAQKBgGDp\nZzIzDDEAs15Wopv2h1NUEW9DUQCxGIHo6TauDfjpoC6IPF+LZHh/vcq2Z1/wb+kJ\n9s3MKBFQRcWm+ER6xa3ihjC2HE2D+0LjAg8pF4t+dZtutyUi+CJEWenQhuesyshk\nP/l0CdeVEpHzVrS1plOOjmLRL7LbDApuNU70PwnBAoGATW/Ry4+kZBW8c6mkQ5X1\nm7ZHexV34C2UtEVZG5xjVWy5uBZv6phOu59vCaeFNBh37aRPVpCJ/r+841mHb2gs\nIa+Yk4gWaoNc+lk+nY9Es8hi0blf030DnO8Cf4M0VDTeX1z1jXQ5PTsKfr3nvHGX\n+CNkUzwkKWSRZw0ljWEkxX4=\n-----END PRIVATE KEY-----\n",
  "client_email": "adf-632@sheety-test-247715.iam.gserviceaccount.com",
  "client_id": "117902490296234934718",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/adf-632%40sheety-test-247715.iam.gserviceaccount.com"
}''';

  static final _sheetId = '1Kxal0CpMm8BPS0AtRTz1QJxnD-LdgKRkf_lwSfQOsRM';
  static Worksheet? _menuSheet;
  static Worksheet? _salesSheet;
  static Worksheet? _todaySalesSheet;

  static final _gsheets = GSheets(_credentials);

  Future init() async {
    final ss = await _gsheets.spreadsheet(_sheetId);
    _salesSheet = await _getWorkSheet(ss, title: 'sales');
    _todaySalesSheet = await _getWorkSheet(ss, title: 'salesByDay');
    _menuSheet = await _getWorkSheet(ss, title: 'menu');
    final salesHeaders = CoffeeSaleFields.getFields();
  }

  Future submitSale(String name, double price, int amount) async {
    final sale = new OneSale(name, price, amount, DateTime.now());
    return _salesSheet!.values.map.appendRow(sale.toJson());
  }

  Future addItemToMenu(String newName, double newPrice) async {
    final newMenuItem = NewMenuItem(newName, newPrice);
    return _menuSheet!.values.map.appendRow(newMenuItem.toJson());
  }

  Future<List<CoffeeItem>> getMenu() async {
    final values = await _menuSheet!.values.map.allRows();
    return values!.map((value) => CoffeeItem.fromJson(value)).toList();
  }

  Future<List<OneSale>> getAggSalesData() async {
    final values = (await _todaySalesSheet!.values.map.allRows());
    return values!.map((value) => OneSale.fromJson(value)).toList();
  }

  Future<Worksheet> _getWorkSheet(Spreadsheet ss,
      {required String title}) async {
    return ss.worksheetByTitle(title)!;
  }
}

class NewMenuItem {
  String name = '';
  double price = 0;
  NewMenuItem(this.name, this.price);
  Map<String, dynamic> toJson() => {
    CoffeeSaleFields.name: this.name,
    CoffeeSaleFields.price: this.price,
  };
}