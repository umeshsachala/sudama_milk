import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sudama_milk/screens/profile_screen.dart';
import 'CustomerListScreen.dart';
import 'item_management/items_list_screen.dart';
import 'item_management/stock_in_screen.dart';
import 'item_management/stock_out_screen.dart';
import 'item_management/item_detail_screen.dart';
import 'onboarding_screen.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn.instance.signOut();

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
      );
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  final user = FirebaseAuth.instance.currentUser;

  String get googleName =>
      user?.displayName ??
          (user?.email != null ? user!.email!.split('@').first : 'Google User');

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
              color: Colors.green, // fallback (optional)
              gradient: LinearGradient(
                colors: [
                  Color(0xFF388E3C), // green shade700
                  Color(0xFF2E7D32), // green shade800 (slightly darker)
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
              const SizedBox(width: 15),
              const Text(
                "ItemTrack",
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
                          Text(
                            "$totalItems",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Total Stock",
                              style: TextStyle(color: Colors.grey)),
                          Text(
                            "$totalStock",
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
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
            MaterialPageRoute(builder: (_) => ItemsListScreen()),
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
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StockInScreen()),
                );
              },
              child: const Text("Stock In"),
            ),
            ElevatedButton(
              style:
              ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const StockOutScreen()),
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
              color: Colors.green
            ),
            accountName: Text(googleName),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage:
              user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person,
                  size: 40, color: Colors.deepPurple)
                  : null,
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
            title: const Text("Customers"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CustomerListScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text("Items"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ItemsListScreen()),
              );
            },
          ),

          const Spacer(),
          const Divider(),

          /// LOGOUT
          ListTile(
            leading:
            const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              Navigator.pop(context);
              await _logout();
            },
          ),
        ],
      ),
    );
  }
}
