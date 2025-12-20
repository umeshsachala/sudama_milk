import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:intl/intl.dart';

import 'edit_transactio_screen.dart';

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
  DateTime? _fromDate;
  DateTime? _toDate;

  String _agoTime(dynamic ts) {
    if (ts == null) return '';
    if (ts is Timestamp) return timeago.format(ts.toDate());
    return '';
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '--';
    return DateFormat('dd MMM yyyy').format(d);
  }

  // ---------------- UPDATE STOCK ----------------
  Future<void> _updateStock(int diff) async {
    await itemsRef.doc(widget.itemId).update({
      'stock': FieldValue.increment(diff),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ---------------- DELETE TRANSACTION ----------------
  Future<void> _deleteTransaction(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final int qty = data['qty'];
    final String type = data['type'];

    final int diff = type == 'in' ? -qty : qty;

    await _updateStock(diff);
    await doc.reference.delete();
  }

  // ---------------- FILTER SHEET ----------------
  void _openFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheet) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filter Transactions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  const Text("Type"),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: [
                      _typeChip(setSheet, "All", 'all'),
                      _typeChip(setSheet, "Stock In", 'in'),
                      _typeChip(setSheet, "Stock Out", 'out'),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text("Date Range"),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheet(() {
                          _fromDate = picked.start;
                          _toDate = DateTime(
                            picked.end.year,
                            picked.end.month,
                            picked.end.day,
                            23,
                            59,
                            59,
                          );
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_formatDate(_fromDate)} → ${_formatDate(_toDate)}",
                          ),
                          const Icon(Icons.date_range),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      child: const Text("Apply Filter"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _typeChip(Function setSheet, String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _filter == value,
      onSelected: (_) {
        setSheet(() => _filter = value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilterSheet,
          )
        ],
      ),
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
                final ts = data['updatedAt'];

                return Container(
                  padding: const EdgeInsets.all(16),
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
                            _agoTime(ts),
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

                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;

                    if (_filter != 'all' && data['type'] != _filter) {
                      return false;
                    }

                    if (_fromDate != null && _toDate != null) {
                      final ts =
                      (data['timestamp'] as Timestamp).toDate();
                      if (ts.isBefore(_fromDate!) ||
                          ts.isAfter(_toDate!)) return false;
                    }
                    return true;
                  }).toList();

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

                      final isIn = data['type'] == 'in';
                      final qty = data['qty'] ?? 0;
                      final ts = data['timestamp'];

                      final customerName = data['customerName'];
                      final customerPhone = data['customerPhone'];

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
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
                                  if (!isIn &&
                                      customerName != null &&
                                      customerPhone != null)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 6),
                                      child: Text(
                                        "$customerName ($customerPhone)",
                                        style:
                                        const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _agoTime(ts),
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            // -------- POPUP MENU (ADDED ONLY) --------
                            PopupMenuButton(
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                    value: 'edit', child: Text("Edit")),
                                PopupMenuItem(
                                    value: 'delete', child: Text("Delete")),
                              ],
                              onSelected: (v) {
                                if (v == 'edit') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditTransactionScreen(
                                        itemId: widget.itemId,
                                        txDoc: docs[index],
                                      ),
                                    ),
                                  );
                                }
                                if (v == 'delete') {
                                  _deleteTransaction(docs[index]);
                                }
                              },
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
