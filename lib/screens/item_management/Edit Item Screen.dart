import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditItemScreen extends StatefulWidget {
  final String docId;
  final String name;
  final int stock;

  const EditItemScreen({
    super.key,
    required this.docId,
    required this.name,
    required this.stock,
  });

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController stockCtrl;
  bool loading = false;

  final itemsRef = FirebaseFirestore.instance.collection('items');

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
    stockCtrl = TextEditingController(text: widget.stock.toString());
  }

  Future<void> _update() async {
    setState(() => loading = true);

    await itemsRef.doc(widget.docId).update({
      'name': nameCtrl.text.trim(),
      'stock': int.tryParse(stockCtrl.text) ?? 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Item"),
        backgroundColor: const Color(0xFF6A5AE0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Stock",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A5AE0),
                ),
                onPressed: loading ? null : _update,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Item"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
