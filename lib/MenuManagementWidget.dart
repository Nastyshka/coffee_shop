import 'package:coffee_tracker/ManageMenuItem.dart';
import 'package:coffee_tracker/GSheetsAPI.dart';
import 'package:coffee_tracker/MyMenuItem.dart';
import 'package:flutter/material.dart';

class MenuManagementWidget extends StatelessWidget {
  MenuManagementWidget(
      {Key? key,
      required this.menuItems,
      required this.provider,
      required this.updateParentFunction})
      : super(key: key);

  final GSheetsAPI provider;
  final Future<List<MyMenuItem>> menuItems;
  double todayTotal = 0;
  VoidCallback updateParentFunction;

  updateTotals(double addValue) {
    todayTotal += addValue;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MyMenuItem>>(
        future: menuItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final menuItems = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  ManageMenuItem ci = ManageMenuItem(
                      name: menuItems[index].name,
                      price: menuItems[index].price,
                      id: menuItems[index].id,
                      provider: provider,
                      updateParentFunction: reloadMenuPage);
                  return ci;
                }),
          );
        });
  }

  reloadMenuPage() {
    updateParentFunction();
  }
}
