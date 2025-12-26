import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');
  final CollectionReference txRef =
  FirebaseFirestore.instance.collection('stock_transactions');

  String? _selectedId;
  String? _selectedName;
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  bool _isLoading = false;

  String? lastItemName;
  int? lastQty;
  String? lastTime;

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
        "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final tx = {
      'itemId': _selectedId,
      'itemName': _selectedName ?? '',
      'type': 'in',
      'qty': qty,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await itemsRef.doc(_selectedId).update({
        'stock': FieldValue.increment(qty),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await txRef.add(tx);

      setState(() {
        lastItemName = _selectedName;
        lastQty = qty;
        lastTime = formattedTime;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Stock added')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ================= APP BAR (UNCHANGED) =================
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
      // ======================================================

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
                  // ---------- ITEM DROPDOWN ----------
                  StreamBuilder<QuerySnapshot>(
                    stream: itemsRef.orderBy('name').snapshots(),
                    builder: (context, snap) {
                      if (!snap.hasData) {
                        return const CircularProgressIndicator();
                      }

                      final docs = snap.data!.docs;

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
                              final data = d.data() as Map<String, dynamic>;
                              return DropdownMenuItem(
                                value: d.id,
                                child: Text(data['name']),
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

                  // ---------- QTY FIELD ----------
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(0xFF263238), // charcoal (non-green)
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
}
