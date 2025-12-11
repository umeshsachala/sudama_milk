import 'dart:convert';

import 'package:flutter/material.dart';
import 'item_management/add_item_screen.dart';
import 'item_management/stock_in_screen.dart';
import 'item_management/stock_out_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  List<Map<String, dynamic>> products = [];

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    int totalItems = products.length;
    int totalStock = products.fold<int>(
      0,
          (sum, item) => sum + (item["stock"] as int? ?? 0),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sudama Milk"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade50,
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text("Total Items",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text("$totalItems",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text("Total Stock",
                          style: TextStyle(fontSize: 14, color: Colors.grey)),
                      Text("$totalStock",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: products.isEmpty
                  ? const Center(
                child: Text(
                  "No Items Added",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              )
                  : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, i) {
                  final item = products[i];
                  DateTime updated = item["updatedAt"] ?? DateTime.now();

                  String hour =
                  (updated.hour % 12 == 0 ? 12 : updated.hour % 12)
                      .toString()
                      .padLeft(2, '0');
                  String minute =
                  updated.minute.toString().padLeft(2, '0');
                  String period = updated.hour >= 12 ? "PM" : "AM";

                  return Card(
                    child: ListTile(
                      title: Text(item["name"]),
                      subtitle: Text(
                        "Stock: ${item["stock"]}\n"
                            "Last update: $hour:$minute $period  ${updated.day}/${updated.month}/${updated.year}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // -------------------------
      // FLOATING CENTER BUTTON
      // -------------------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddItemScreen(products, refresh),
            ),
          );
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // -------------------------------------
      // BOTTOM BAR WITH STOCK IN / STOCK OUT
      // -------------------------------------
      bottomNavigationBar: Container(
        height: 100,
       // color: Colors.deepPurple.shade50,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // STOCK IN
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              onPressed: () {
                if (products.isEmpty) {
                  showError("Please add an item first.");
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockInScreen(products, refresh),
                  ),
                );
              },
              child: const Text(
                "Stock In",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            // STOCK OUT
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              ),
              onPressed: () {
                if (products.isEmpty) {
                  showError("Please add an item first.");
                  return;
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockOutScreen(products, refresh),
                  ),
                );
              },
              child: const Text(
                "Stock Out",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
