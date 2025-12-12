import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'item_management/add_item_screen.dart';
import 'item_management/stock_in_screen.dart';
import 'item_management/stock_out_screen.dart';
import 'item_management/item_detail_screen.dart'; // new import

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final CollectionReference itemsRef = FirebaseFirestore.instance.collection('items');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,

          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
          ),

          titleSpacing: 0,

          title: Row(
            children: [
              const SizedBox(width: 12),

              // Left Icon (Glow Effect)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard_customize_rounded,
                  size: 26,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 12),

              // Title
              const Text(
                "Sudama Milk",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        child: Column(
          children: [
            // STATS: get totals from snapshot
            StreamBuilder<QuerySnapshot>(
              stream: itemsRef.snapshots(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Text('Error loading stats');
                }
                if (!snap.hasData) {
                  return Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                final docs = snap.data!.docs;
                final totalItems = docs.length;
                int totalStock = 0;
                for (var d in docs) {
                  final s = d.get('stock') ?? 0;
                  totalStock += (s is int) ? s : int.tryParse(s.toString()) ?? 0;
                }

                return Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("Total Items", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text("$totalItems", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Total Stock", style: TextStyle(fontSize: 14, color: Colors.grey)),
                          Text("$totalStock", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // ITEMS LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: itemsRef.orderBy('updatedAt', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Error loading items"));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(
                      child: Text("No Items Added", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['name'] ?? 'Unnamed';
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
                      final hour = (updated.hour % 12 == 0 ? 12 : updated.hour % 12).toString().padLeft(2, '0');
                      final minute = updated.minute.toString().padLeft(2, '0');
                      final period = updated.hour >= 12 ? "PM" : "AM";

                      return Card(
                        child: ListTile(
                          title: Text(name),
                          subtitle: Text("Stock: $stock\nLast update: $hour:$minute $period  ${updated.day}/${updated.month}/${updated.year}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(itemId: doc.id, itemName: name),
                              ),
                            );
                          },
                          // trailing: PopupMenuButton<String>(
                          //   onSelected: (v) async {
                          //     if (v == 'delete') {
                          //       await itemsRef.doc(doc.id).delete();
                          //     } else if (v == 'edit') {
                          //       // optional: implement edit dialog or screen
                          //     }
                          //   },
                          //   itemBuilder: (_) => const [
                          //     PopupMenuItem(value: 'edit', child: Text('Edit')),
                          //     PopupMenuItem(value: 'delete', child: Text('Delete')),
                          //   ],
                          // ),
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

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddItemScreen()));
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: Container(
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockInScreen()));
              },
              child: const Text("Stock In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StockOutScreen()));
              },
              child: const Text("Stock Out", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
