import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditCustomerScreen extends StatefulWidget {
  final String docId;
  final String name;
  final String phone;

  const EditCustomerScreen({
    super.key,
    required this.docId,
    required this.name,
    required this.phone,
  });

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  bool loading = false;

  final customerRef =
  FirebaseFirestore.instance.collection('customers');

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
    phoneCtrl = TextEditingController(text: widget.phone);
  }

  Future<void> _update() async {
    if (nameCtrl.text.trim().isEmpty ||
        phoneCtrl.text.trim().isEmpty) return;

    setState(() => loading = true);

    await customerRef.doc(widget.docId).update({
      'name': nameCtrl.text.trim(),
      'phone': phoneCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Customer"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: "Customer Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: "Phone Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: loading ? null : _update,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Update Customer",
                  style: TextStyle(fontSize: 18,color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
