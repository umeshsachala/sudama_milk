import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

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

  /// 🔥 AGO TIME FUNCTION
  String agoTime(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) {
      return timeago.format(ts.toDate());
    } else if (ts is DateTime) {
      return timeago.format(ts);
    }
    return '';
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
            // 🔹 ITEM SUMMARY
            StreamBuilder<DocumentSnapshot>(
              stream: itemsRef.doc(widget.itemId).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snap.data!.data() as Map<String, dynamic>;
                final stock = data['stock'] ?? 0;
                final updatedAt = data['updatedAt'];

                return Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.05),
                        blurRadius: 8,
                      )
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
                          Text(
                            "$stock",
                            style: const TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Last Updated",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(
                            agoTime(updatedAt), // 🔥 AGO TIME HERE
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Transactions",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 TRANSACTION LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: txRef
                    .where('itemId', isEqualTo: widget.itemId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                        child: Text("No transactions yet",
                            style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;
                      final isIn =
                          (data['type'] ?? '').toString().toLowerCase() == 'in';

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT
                            Column(
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
                                Text("Qty: ${data['qty'] ?? 0}"),
                              ],
                            ),

                            // RIGHT
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  agoTime(data['timestamp']), // 🔥 AGO TIME
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                                if (data['user'] != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    data['user'],
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ]
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
