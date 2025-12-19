import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser!;

  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: user.displayName ?? '');
    phoneCtrl = TextEditingController();
    _loadLocalPhone();
  }

  Future<void> _loadLocalPhone() async {
    final prefs = await SharedPreferences.getInstance();
    phoneCtrl.text = prefs.getString('local_phone') ?? '';
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    // Save name in Firebase Auth
    await user.updateDisplayName(nameCtrl.text.trim());
    await user.reload();

    // Save phone locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_phone', phoneCtrl.text.trim());

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Saved")),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  InputDecoration _input(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),

              const SizedBox(height: 25),

              // NAME (Saved in Firebase Auth)
              TextField(
                controller: nameCtrl,
                decoration: _input("Name", Icons.person),
              ),

              const SizedBox(height: 14),

              // EMAIL (Always from Google Login)
              TextField(
                enabled: false,
                decoration: _input("Email", Icons.email)
                    .copyWith(hintText: user.email),
              ),

              const SizedBox(height: 14),

              // PHONE (Saved locally)
              TextField(
                controller: phoneCtrl,
                decoration: _input("Phone", Icons.phone),
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
