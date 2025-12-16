import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _shopCtrl = TextEditingController();
  bool _loading = false;

  final docRef =
  FirebaseFirestore.instance.collection('profile').doc('owner');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await docRef.get();
    if (doc.exists) {
      final d = doc.data()!;
      _nameCtrl.text = d['name'] ?? '';
      _shopCtrl.text = d['shop'] ?? '';
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    await docRef.set({
      'name': _nameCtrl.text.trim(),
      'shop': _shopCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    setState(() => _loading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: "Owner Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _shopCtrl,
              decoration: const InputDecoration(
                labelText: "Shop Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple),
                onPressed: _loading ? null : _save,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SAVE",
                    style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
