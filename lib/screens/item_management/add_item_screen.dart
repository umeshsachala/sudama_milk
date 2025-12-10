import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  final List products;
  final VoidCallback refresh;

  const AddItemScreen(this.products, this.refresh, {super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Item"),
        backgroundColor: const Color(0xFF6A11CB),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A11CB),
              ),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.products.add({
                    "name": controller.text.trim(),
                    "stock": 0,
                  });
                  widget.refresh();
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Item"),
            )
          ],
        ),
      ),
    );
  }
}
