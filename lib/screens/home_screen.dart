import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sudama_milk/screens/profile_screen.dart';
import 'add_customer_screen.dart';
import 'item_management/add_item_screen.dart';
import 'item_management/stock_in_screen.dart';
import 'item_management/stock_out_screen.dart';
import 'item_management/item_detail_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _appDrawer(context),

      // ---------------- APP BAR ----------------
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

              GestureDetector(
                onTap: () => _scaffoldKey.currentState!.openDrawer(),
                child: Container(
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
              ),

              const SizedBox(width: 12),

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

      // ---------------- BODY ----------------
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------- STATS --------
            StreamBuilder<QuerySnapshot>(
              stream: itemsRef.snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const CircularProgressIndicator();
                }

                final docs = snap.data!.docs;
                final totalItems = docs.length;
                int totalStock = 0;

                for (var d in docs) {
                  totalStock += (d['stock'] ?? 0) as int;
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
                          const Text("Total Items",
                              style: TextStyle(color: Colors.grey)),
                          Text("$totalItems",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Total Stock",
                              style: TextStyle(color: Colors.grey)),
                          Text("$totalStock",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // -------- ITEM LIST --------
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: itemsRef
                    .orderBy('updatedAt', descending: true)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final docs = snap.data!.docs;
                  if (docs.isEmpty) {
                    return const Center(child: Text("No Items Found"));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final doc = docs[i];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          title: Text(data['name'] ?? ''),
                          subtitle:
                          Text("Stock: ${data['stock'] ?? 0}"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemDetailScreen(
                                  itemId: doc.id,
                                  itemName: data['name'],
                                ),
                              ),
                            );
                          },
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

      // ---------------- FAB ----------------
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddItemScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ---------------- BOTTOM BAR ----------------
      bottomNavigationBar: Container(
        height: 90,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockInScreen()),
                );
              },
              child: const Text("Stock In"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StockOutScreen()),
                );
              },
              child: const Text("Stock Out"),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DRAWER ----------------
  Widget _appDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
            ),
            accountName: const Text("Sudama Milk"),
            accountEmail: const Text("Milk Management"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person,
                  size: 40, color: Colors.deepPurple),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Profile"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.group_add),
            title: const Text("Add Customer"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
              );
            },
          ),

          SizedBox(height: 400,),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout",
                style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
