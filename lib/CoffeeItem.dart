import 'package:coffee_tracker/CoffeeSaleFields.dart';

class CoffeeItem {
  String name = '';
  double price = 0;
  int amountSold = 0;

  CoffeeItem(this.name, this.price, this.amountSold);

  Map<String, dynamic> toJson() => {
        CoffeeSaleFields.name: this.name,
        CoffeeSaleFields.price: this.price,
        CoffeeSaleFields.amountSold: this.amountSold
      };

  static CoffeeItem fromJson(Map<String, dynamic> json) => CoffeeItem(
      json[CoffeeSaleFields.name],
      double.parse(json[CoffeeSaleFields.price]),
      0
      // int.parse(json[CoffeeSaleFields.ampuntSold]!)
  );
}
