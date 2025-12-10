import 'package:firebase_auth/firebase_auth.dart';
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
  // product = {name, stock, updatedAt}

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
        backgroundColor: const Color(0xFF6A11CB),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            // ============================
            // Summary Section
            // ============================
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

            // ============================
            // Product List
            // ============================
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

                  // -------------------------
                  // Format Time with AM/PM
                  // -------------------------
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
                            "Last update: $hour:$minute $period  "
                            "${updated.day}/${updated.month}/${updated.year}",
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ============================
      // Bottom Buttons Section
      // ============================
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                spreadRadius: 1)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            buildBottomButton(
              icon: Icons.add_circle,
              label: "Add Item",
              color: Colors.green,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddItemScreen(products, refresh)),
                );
              },
            ),
            buildBottomButton(
              icon: Icons.upload,
              label: "Stock In",
              color: Colors.blue,
              onTap: () async {
                if (products.isEmpty) {
                  showError("Please add an item first.");
                  return;
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => StockInScreen(products, refresh)),
                );
              },
            ),
            buildBottomButton(
              icon: Icons.download,
              label: "Stock Out",
              color: Colors.red,
              onTap: () async {
                if (products.isEmpty) {
                  showError("Please add an item first.");
                  return;
                }
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => StockOutScreen(products, refresh)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bottom buttons (small round)
  Widget buildBottomButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  void showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
