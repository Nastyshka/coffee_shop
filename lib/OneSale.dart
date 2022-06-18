import 'package:coffee_tracker/CoffeeSaleFields.dart';

class OneSale {
  String name = '';
  double price = 0;
  int amountSold = 0;
  DateTime saleDate = DateTime.now();

  OneSale(this.name, this.price, this.amountSold, this.saleDate);

  Map<String, dynamic> toJson() =>
      {
        CoffeeSaleFields.name: this.name,
        CoffeeSaleFields.price: this.price,
        CoffeeSaleFields.amountSold: this.amountSold,
        CoffeeSaleFields.saleDate: this.saleDate.toString()
      };

  static OneSale fromJson(Map<String, dynamic> json) =>
      OneSale(
          json[CoffeeSaleFields.name],
          double.parse(json[CoffeeSaleFields.price]!),
          int.parse(json[CoffeeSaleFields.amountSold]!),
          DateTime.fromMillisecondsSinceEpoch((int.parse(json[CoffeeSaleFields.saleDate]!)-25569)*86400000));
}
