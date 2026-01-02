import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  late final CollectionReference itemsRef;
  late final CollectionReference txRef;

  String? _selectedId;
  String? _selectedName;

  final TextEditingController _qtyCtrl =
  TextEditingController(text: '1');

  bool _isLoading = false;

  String? lastItemName;
  int? lastQty;
  String? lastTime;

  @override
  void initState() {
    super.initState();

    /// ✅ SAME AS HOME SCREEN
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
    if (_selectedId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select item')));
      return;
    }

    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid qty')));
      return;
    }

    setState(() => _isLoading = true);

    final now = DateTime.now();
    final formattedTime =
        "${now.day}/${now.month}/${now.year}  "
        "${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    try {
      /// 🔼 UPDATE STOCK
      await itemsRef.doc(_selectedId).update({
        'stock': FieldValue.increment(qty),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      /// 🧾 SAVE TRANSACTION
      await txRef.add({
        'itemId': _selectedId,
        'itemName': _selectedName ?? '',
        'type': 'in',
        'qty': qty,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        lastItemName = _selectedName;
        lastQty = qty;
        lastTime = formattedTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock added')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APP BAR =================
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
            "Add Stock",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
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
                  /// ITEM DROPDOWN (USER-WISE)
                  StreamBuilder<QuerySnapshot>(
                    stream: itemsRef.orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snap.data!.docs;

                      if (docs.isEmpty) {
                        return const Text("No items available");
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedId,
                            hint: const Text("Select Item"),
                            isExpanded: true,
                            items: docs.map((d) {
                              final data =
                              d.data() as Map<String, dynamic>;
                              return DropdownMenuItem<String>(
                                value: d.id,
                                child: Text(
                                  "${data['name']} (Stock ${data['stock'] ?? 0})",
                                ),
                              );
                            }).toList(),
                            onChanged: (v) {
                              final sel =
                              docs.firstWhere((e) => e.id == v);
                              final data =
                              sel.data() as Map<String, dynamic>;
                              setState(() {
                                _selectedId = v;
                                _selectedName = data['name'];
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

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

            SizedBox(
              width: double.infinity,
              height: 54,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF263238),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Add Stock",
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
}
