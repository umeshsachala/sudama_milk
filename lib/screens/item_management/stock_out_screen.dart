import 'package:flutter/material.dart';

class StockOutScreen extends StatefulWidget {
  final List products;
  final VoidCallback refresh;

  const StockOutScreen(this.products, this.refresh, {super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  String? selectedItem;
  final TextEditingController qtyController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stock Out"), backgroundColor: const Color(0xFF6A11CB)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            DropdownButtonFormField(
              decoration: const InputDecoration(border: OutlineInputBorder()),
              value: selectedItem,
              hint: const Text("Select Item"),
              items: widget.products.map((item) {
                return DropdownMenuItem(
                  value: item["name"],
                  child: Text(item["name"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => selectedItem = value as String?);
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
              onPressed: () {
                if (selectedItem != null && qtyController.text.isNotEmpty) {
                  int qty = int.parse(qtyController.text);
                  var product = widget.products.firstWhere((p) => p["name"] == selectedItem);

                  if (product["stock"] >= qty) {
                    product["stock"] -= qty;
                    widget.refresh();
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Not enough stock")),
                    );
                  }
                }
              },
              child: const Text("Reduce Stock"),
            )
          ],
        ),
      ),
    );
  }
}
