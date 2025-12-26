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
      // ================= APP BAR (SAME THEME) =================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF388E3C),
                  Color(0xFF2E7D32),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),
          title: const Text(
            "Stock Out",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
      ),
      // =======================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ================= FORM CARD =================
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
                      return _dropdown(
                        hint: "Select Item",
                        value: _itemId,
                        items: snap.data!.docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
                            value: d.id,
                            child: Text(
                              "${data['name']} (Stock ${data['stock']})",
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

                  /// CUSTOMER DROPDOWN
                  StreamBuilder<QuerySnapshot>(
                    stream: customerRef.orderBy('name').snapshots(),
                    builder: (_, snap) {
                      if (!snap.hasData) {
                        return const CircularProgressIndicator();
                      }
                      return _dropdown(
                        hint: "Select Customer",
                        value: _customerId,
                        items: snap.data!.docs.map((d) {
                          final data = d.data() as Map<String, dynamic>;
                          return DropdownMenuItem(
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

                  /// QTY FIELD
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

            // ================= SUBMIT BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 54,
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF37474F), // dark slate (non-red)
                  elevation: 4,
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
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DROPDOWN WIDGET (UI ONLY) =================
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
