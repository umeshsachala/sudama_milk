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

  // Last added details
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
    final now = DateTime.now();
    final currentFormattedTime =
        "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // enables back button
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: const [
            SizedBox(width: 10),
            Text(
              "Sudama Milk",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                )
              ],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --------------------------------------------
                // DROPDOWN
                // --------------------------------------------
                StreamBuilder<QuerySnapshot>(
                  stream: itemsRef.orderBy('name').snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snap.data!.docs;

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedId,
                          hint: const Text("Select Item"),
                          items: docs.map((d) {
                            final data = d.data() as Map<String, dynamic>;
                            return DropdownMenuItem(
                              value: d.id,
                              child: Text(data['name']),
                            );
                          }).toList(),
                          onChanged: (v) {
                            final sel = docs.firstWhere((e) => e.id == v);
                            final data = sel.data() as Map<String, dynamic>;

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

                const SizedBox(height: 16),

                // QTY FIELD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: "Enter Quantity",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // BUTTON
                SizedBox(
                  width: double.infinity,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _submit,
                    child: const Text(
                      "Add Stock",
                      style: TextStyle(fontSize: 20,color: Colors.white),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // CURRENT TIME
                Text(
                  "Current Time: $currentFormattedTime",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 20),

                // LAST ADDED STOCK INFO
                if (lastItemName != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Last Stock Added:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text("Item: $lastItemName"),
                        Text("Quantity: $lastQty"),
                        Text("Time: $lastTime"),
                      ],
                    ),
                  ),

                const SizedBox(height: 25),

                // ---------------------------------------------------------
                // FULL STOCK-IN HISTORY FOR SELECTED ITEM
                // ---------------------------------------------------------
                if (_selectedId != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Stock In History:",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),

                      StreamBuilder<QuerySnapshot>(
                        stream: txRef
                            .where("itemId", isEqualTo: _selectedId)
                            .where("type", isEqualTo: "in")
                            .orderBy("timestamp", descending: true)
                            .snapshots(),
                        builder: (context, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final txDocs = snap.data!.docs;

                          if (txDocs.isEmpty) {
                            return const Text(
                              "No stock-in history available.",
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return Column(
                            children: txDocs.map((doc) {
                              final data =
                              doc.data() as Map<String, dynamic>;
                              final ts = data['timestamp'] as Timestamp?;
                              final dt = ts?.toDate();
                              final time = dt == null
                                  ? "No time"
                                  : "${dt.day}/${dt.month}/${dt.year}  ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                              return Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text("Qty: ${data['qty']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        Text("Time: $time"),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
