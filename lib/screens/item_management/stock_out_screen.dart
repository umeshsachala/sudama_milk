import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  late final CollectionReference itemsRef;
  final CollectionReference customerRef =
  FirebaseFirestore.instance.collection('customers');
  late final CollectionReference txRef;

  String? _itemId;
  String? _itemName;

  String? _customerId;
  String? _customerName;
  String? _customerPhone;

  final _qtyCtrl = TextEditingController(text: '1');
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    /// ✅ SAME AS HOME SCREEN (USER-WISE ITEMS)
    itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('items');

    /// ✅ USER-WISE TRANSACTIONS
    txRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('stock_transactions');
  }

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

    if (!snap.exists) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item not found')),
      );
      return;
    }

    final stock = (snap['stock'] ?? 0) as int;

    if (stock < qty) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient stock')),
      );
      return;
    }

    /// 🔻 UPDATE STOCK
    await itemDoc.update({
      'stock': FieldValue.increment(-qty),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    /// 🧾 SAVE TRANSACTION
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

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF388E3C), Color(0xFF2E7D32)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          centerTitle: true,
          title: const Text(
            "Stock Out",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  /// ITEM DROPDOWN
                  StreamBuilder<QuerySnapshot>(
                    stream: itemsRef.orderBy('name').snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const CircularProgressIndicator();
                      }

                      if (snap.data!.docs.isEmpty) {
                        return const Text("No items available");
                      }

                      return _dropdown(
                        hint: "Select Item",
                        value: _itemId,
                        items: snap.data!.docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(
                              "${data['name']} (Stock ${data['stock'] ?? 0})",
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          final d = snap.data!.docs
                              .firstWhere((e) => e.id == v);
                          setState(() {
                            _itemId = v;
                            _itemName = d['name'];
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  /// ✅ CUSTOMER DROPDOWN (GLOBAL – FIXED)
                  StreamBuilder<QuerySnapshot>(
                    stream: customerRef.orderBy('createdAt').snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const CircularProgressIndicator();
                      }

                      if (snap.data!.docs.isEmpty) {
                        return const Text("No customers found");
                      }

                      return _dropdown(
                        hint: "Select Customer",
                        value: _customerId,
                        items: snap.data!.docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem<String>(
                            value: d.id,
                            child: Text(
                              "${data['name']} (${data['phone']})",
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          final d = snap.data!.docs
                              .firstWhere((e) => e.id == v);
                          setState(() {
                            _customerId = v;
                            _customerName = d['name'];
                            _customerPhone = d['phone'];
                          });
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Enter Quantity",
                      prefixIcon:
                      const Icon(Icons.confirmation_number_outlined),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Remove Stock",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
