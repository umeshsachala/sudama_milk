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

  String _filter = 'all'; // all | in | out

  // 🔥 AGO TIME FUNCTION (ONLY ADDITION)
  String _agoTime(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) {
      return timeago.format(ts.toDate());
    } else if (ts is DateTime) {
      return timeago.format(ts);
    }
    return '';
  }

  // (Kept for safety, not used now)
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
      // ---------------- APP BAR ----------------
      appBar: AppBar(
        title: Text(widget.itemName),
        backgroundColor: Colors.deepPurple,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _filter,
                dropdownColor: Colors.white,
                icon: const Icon(Icons.filter_list, color: Colors.white),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All')),
                  DropdownMenuItem(value: 'in', child: Text('Stock In')),
                  DropdownMenuItem(value: 'out', child: Text('Stock Out')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _filter = v);
                },
              ),
            ),
          )
        ],
      ),

      // ---------------- BODY ----------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- ITEM SUMMARY ----------------
            StreamBuilder<DocumentSnapshot>(
              stream: itemsRef.doc(widget.itemId).snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final data = snap.data!.data() as Map<String, dynamic>;
                final stock = data['stock'] ?? 0;
                final ts = data['updatedAt'] as Timestamp?;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.04),
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
                            _agoTime(ts), // 🔥 AGO TIME
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

            // ---------------- TRANSACTIONS ----------------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: txRef
                    .where('itemId', isEqualTo: widget.itemId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const CircularProgressIndicator();
                  }

                  var docs = snap.data!.docs;

                  // APPLY FILTER
                  if (_filter != 'all') {
                    docs = docs.where((d) {
                      final type =
                      (d['type'] ?? '').toString().toLowerCase();
                      return type == _filter;
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No transactions found",
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: docs.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final data =
                      docs[index].data() as Map<String, dynamic>;

                      final isIn =
                          data['type'].toString().toLowerCase() == 'in';
                      final qty = data['qty'] ?? 0;
                      final ts = data['timestamp'] as Timestamp?;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isIn ? "Stock In" : "Stock Out",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                    isIn ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Qty: $qty"),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _agoTime(ts), // 🔥 AGO TIME
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey),
                                ),
                                if (data['user'] != null)
                                  Text(
                                    "${data['user']}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
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
