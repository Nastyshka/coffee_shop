import 'CoffeeSaleFields.dart';

class MyMenuItem {
  String name = '';
  double price = 0;
  int id = 0;

  MyMenuItem(this.name, this.price);

  Map<String, dynamic> toJson() =>
      {
        CoffeeSaleFields.name: this.name,
        CoffeeSaleFields.price: this.price,
        CoffeeSaleFields.id: this.id,
      };

  static MyMenuItem fromJson(Map<String, dynamic> json) {
    MyMenuItem res = MyMenuItem
      (
      json[CoffeeSaleFields.name],
      double.parse(json[CoffeeSaleFields.price]),
    );
    res.id = int.parse(json[CoffeeSaleFields.id]);
    return res;
  }
}