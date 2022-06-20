import 'package:coffee_tracker/CoffeeItem.dart';
import 'package:coffee_tracker/CoffeeMenuItem.dart';
import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:flutter/material.dart';

class SalesOfTheDayWidget extends StatelessWidget {
  SalesOfTheDayWidget(
      {Key? key,
      required this.coffees,
      required this.provider,
      required this.selectedDay})
      : super(key: key);

  final GSheetsAPI provider;
  final Future<List<CoffeeItem>> coffees;
  final DateTime selectedDay;
  double todayTotal = 0;

  updateTotals(double addValue) {
    todayTotal += addValue;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CoffeeItem>>(
        future: coffees,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final coffees = snapshot.data!;
          calculateTotalForTheDay(coffees);
          bool isEditable = DateTime.now().day == selectedDay.day &&
              DateTime.now().month == selectedDay.month &&
              DateTime.now().year == selectedDay.year;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: coffees.length,
                itemBuilder: (context, index) {
                  CoffeeMenuItem ci = CoffeeMenuItem(
                      name: coffees[index].name,
                      price: coffees[index].price,
                      amountSold: coffees[index].amountSold,
                      editable: isEditable,
                      provider: provider,
                      updateFunction: updateTotals);
                  if (index == coffees.length-1) {
                    return Column(
                        children: <Widget>[ci, buildTotalButton(context)]);
                  }
                  return ci;
                }),
          );
        });
  }

  Align buildTotalButton(BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
            child: Icon(Icons.collections_bookmark),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                        title: Text('Сума за день ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF0d595a),
                                fontSize: 28,
                                fontWeight: FontWeight.bold)),
                        content: Text('${todayTotal}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 38, fontWeight: FontWeight.bold)),
                      ));
            }));
  }

  void calculateTotalForTheDay(List<CoffeeItem> coffees) {
    todayTotal = 0;
    for (CoffeeItem item in coffees) {
      todayTotal += item.amountSold * item.price;
    }
  }
}
