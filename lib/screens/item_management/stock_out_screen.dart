import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final itemsRef = FirebaseFirestore.instance.collection('items');
  final txRef = FirebaseFirestore.instance.collection('stock_transactions');
  final customerRef = FirebaseFirestore.instance.collection('customers');

  String? _itemId;
  String? _itemName;

  String? _customerId;
  String? _customerName;
  String? _customerPhone;

  final _qtyCtrl = TextEditingController(text: '1');
  bool _loading = false;

  Future<void> _submit() async {
    if (_itemId == null || _customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select item and customer')),
      );
      return;
    }

    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) return;

    setState(() => _loading = true);

    final itemDoc = itemsRef.doc(_itemId);
    final snap = await itemDoc.get();
    final stock = snap['stock'] ?? 0;

    if (stock < qty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Insufficient stock')));
      setState(() => _loading = false);
      return;
    }

    await itemDoc.update({
      'stock': FieldValue.increment(-qty),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await txRef.add({
      'itemId': _itemId,
      'itemName': _itemName,
      'type': 'out',
      'qty': qty,
      'customerId': _customerId,
      'customerName': _customerName,
      'customerPhone': _customerPhone,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Out"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// ITEM DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: itemsRef.orderBy('name').snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();
                return _dropdown(
                  hint: "Select Item",
                  value: _itemId,
                  items: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text("${data['name']} (Stock ${data['stock']})"),
                    );
                  }).toList(),
                  onChanged: (v) {
                    final d =
                    snap.data!.docs.firstWhere((e) => e.id == v);
                    setState(() {
                      _itemId = v;
                      _itemName = d['name'];
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            /// CUSTOMER DROPDOWN
            StreamBuilder<QuerySnapshot>(
              stream: customerRef.orderBy('name').snapshots(),
              builder: (_, snap) {
                if (!snap.hasData) return const CircularProgressIndicator();
                return _dropdown(
                  hint: "Select Customer",
                  value: _customerId,
                  items: snap.data!.docs.map((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: d.id,
                      child: Text("${data['name']} (${data['phone']})"),
                    );
                  }).toList(),
                  onChanged: (v) {
                    final d =
                    snap.data!.docs.firstWhere((e) => e.id == v);
                    setState(() {
                      _customerId = v;
                      _customerName = d['name'];
                      _customerPhone = d['phone'];
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 12),

            /// QTY
            TextField(
              controller: _qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: _loading ? null : _submit,
                child: const Text("REMOVE STOCK"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text(hint),
          value: value,
          items: items,
          isExpanded: true,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
