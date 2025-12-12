import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  final String itemName;

  const ItemDetailScreen({
    Key? key,
    required this.itemId,
    required this.itemName,
  }) : super(key: key);

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');
  final CollectionReference txRef =
  FirebaseFirestore.instance.collection('stock_transactions');

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour =
    (dt.hour % 12 == 0 ? 12 : dt.hour % 12).toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? "PM" : "AM";
    return "$day/$month/$year  $hour:$minute $period";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ITEM SUMMARY (stock, last updated)
            StreamBuilder<DocumentSnapshot>(
              stream: itemsRef.doc(widget.itemId).snapshots(),
              builder: (context, snap) {
                if (snap.hasError) return const Text('Error loading item');
                if (!snap.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final data = snap.data!.data() as Map<String, dynamic>?;
                if (data == null) {
                  return const Text('Item not found');
                }

                final stock = data['stock'] ?? 0;
                final ts = data['updatedAt'];
                DateTime updated;
                if (ts is Timestamp) {
                  updated = ts.toDate();
                } else if (ts is DateTime) {
                  updated = ts;
                } else {
                  updated = DateTime.now();
                }

                return Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 8)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Current Stock",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text("$stock",
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Last Updated",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(_formatDateTime(updated),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Header for transactions
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Transactions",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            // TRANSACTIONS LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: txRef
                    .where('itemId', isEqualTo: widget.itemId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasError)
                    return const Center(child: Text('Error loading transactions'));
                  if (!snap.hasData)
                    return const Center(child: CircularProgressIndicator());

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text("No transactions yet.",
                            style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final d = docs[index];
                      final data = d.data() as Map<String, dynamic>;
                      final type = (data['type'] ?? '').toString();
                      final qty = data['qty'] ?? 0;
                      final ts = data['timestamp'] as Timestamp?;
                      final dt = ts?.toDate();
                      final timeStr = dt == null ? "No time" : _formatDateTime(dt);

                      final isIn = type.toLowerCase() == 'in';

                      // ---- Clean row WITHOUT avatar ----
                      return Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: type + qty
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isIn ? "Stock In" : "Stock Out",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIn
                                          ? Colors.green.shade700
                                          : Colors.red.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Qty: $qty"),
                                ],
                              ),
                            ),

                            // Right: time (and optional user)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(timeStr,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                if (data.containsKey('user') && data['user'] != null)
                                  Text("${data['user']}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
