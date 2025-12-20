import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  final String itemId;
  final DocumentSnapshot txDoc;

  const EditTransactionScreen({
    Key? key,
    required this.itemId,
    required this.txDoc,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController qtyCtrl;

  final itemsRef = FirebaseFirestore.instance.collection('items');

  @override
  void initState() {
    super.initState();
    qtyCtrl =
        TextEditingController(text: widget.txDoc['qty'].toString());
  }

  Future<void> _save() async {
    final int oldQty = widget.txDoc['qty'];
    final int newQty = int.parse(qtyCtrl.text);
    final String type = widget.txDoc['type'];

    final int diff =
    type == 'in' ? newQty - oldQty : oldQty - newQty;

    await itemsRef.doc(widget.itemId).update({
      'stock': FieldValue.increment(diff),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await widget.txDoc.reference.update({
      'qty': newQty,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Transaction"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: const Text("Save Changes"),
              ),
            )
          ],
        ),
      ),
    );
  }
}