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
    print('>>>> add totals ' + addValue.toString());
    todayTotal += addValue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: FutureBuilder<List<CoffeeItem>>(
            future: coffees,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final coffees = snapshot.data!;

              calculateTotalForTheDay(coffees);
              // Widget totalWid = TodayTotalWidget(todayTotal: todayTotal);
              bool isEditable = DateTime.now().day == selectedDay.day &&
                  DateTime.now().month == selectedDay.month &&
                  DateTime.now().year == selectedDay.year;
              return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          // direction: Axis.vertical,
                          children: <Widget>[
                        // Align(alignment: Alignment.topLeft, child: totalWid),
                        SingleChildScrollView(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: coffees.length,
                              itemBuilder: (context, index) => CoffeeMenuItem(
                                  name: coffees[index].name,
                                  price: coffees[index].price,
                                  amountSold: coffees[index].amountSold,
                                  editable: isEditable,
                                  provider: provider,
                                  updateFunction: updateTotals)),
                        ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: FloatingActionButton(
                                child: Icon(Icons.collections_bookmark),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                            title: Text('Total of the day',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    color: Color(0xFF0d595a),
                                                    fontSize: 28,
                                                    fontWeight: FontWeight.bold)),
                                            content: Text('${todayTotal}',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontSize: 38,
                                                    fontWeight: FontWeight.bold)),
                                          ));
                                }))
                      ])));
            }));
  }

  void calculateTotalForTheDay(List<CoffeeItem> coffees) {
    todayTotal = 0;
    for (CoffeeItem item in coffees) {
      todayTotal += item.amountSold * item.price;
    }
  }
}
// class SalesOfTheDayWidget extends StatelessWidget {
//   SalesOfTheDayWidget(
//       {Key? key,
//       required this.coffees,
//       required this.provider,
//       required this.selectedDay})
//       : super(key: key);
//
//   final GSheetsAPI provider;
//   final Future<List<CoffeeItem>> coffees;
//   final DateTime selectedDay;
//   double todayTotal = 0;
//
//   updateTotals(String addValue) {
//     todayTotal += double.parse(addValue);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         child: FutureBuilder<List<CoffeeItem>>(
//             future: coffees,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState != ConnectionState.done) {
//                 return const Center(
//                   child: CircularProgressIndicator(),
//                 );
//               }
//
//               final coffees = snapshot.data!;
//
//               calculateTotalForTheDay(coffees);
//               Widget totalWid = TodayTotalWidget(todayTotal: todayTotal);
//
//               return Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: SingleChildScrollView(
//                       child: Flex(
//                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                           direction: Axis.vertical,
//                           children: <Widget>[
//                         Align(
//                             alignment: Alignment.topLeft,
//                             child: totalWid),
//                         SingleChildScrollView(
//                           child: ListView.builder(
//                               shrinkWrap: true,
//                               itemCount: coffees.length,
//                               itemBuilder: (context, index) => CoffeeMenuItem(
//                                   name: coffees[index].name,
//                                   price: coffees[index].price,
//                                   amountSold: coffees[index].amountSold,
//                                   provider: provider,
//                                   updateFunction: updateTotals)),
//                         )
//                       ])));
//             }));
//   }
//
//   void calculateTotalForTheDay(List<CoffeeItem> coffees) {
//       todayTotal = 0;
//     for (CoffeeItem item in coffees) {
//       todayTotal += item.amountSold * item.price;
//     }
//   }
// }

class TodayTotalWidget extends StatefulWidget {
  const TodayTotalWidget({
    Key? key,
    required this.todayTotal,
  }) : super(key: key);

  final double todayTotal;

  @override
  State<StatefulWidget> createState() =>
      _TodayTotalWidget(todayTotal: todayTotal);
}

class _TodayTotalWidget extends State<TodayTotalWidget> {
  double todayTotal;

  _TodayTotalWidget({required this.todayTotal}) {}

  @override
  void didUpdateWidget(covariant TodayTotalWidget oldWidget) {
    print('>>>> didUpdateWidget');
    if (oldWidget.todayTotal != widget.todayTotal) {
      setState(() {
        todayTotal = widget.todayTotal;
        print('new total :  ' + todayTotal.toString());
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Icon(Icons.wallet, color: Colors.white),
          Text('${todayTotal}₴',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ]),
        padding: const EdgeInsets.all(3),
        width: 80.0,
        decoration: BoxDecoration(
          color: Color(0xFF9B553A),
          border: Border.all(color: Color(0xFFB4662A), width: 3),
          borderRadius: BorderRadius.circular(10),
        ));
  }
}
