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

  // controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();

    // ✅ NAME FROM GOOGLE (displayName OR email fallback)
    nameCtrl.text = user.displayName ??
        (user.email != null ? user.email!.split('@').first : 'Google User');

    emailCtrl.text = user.email ?? '';
    _loadLocalData();
  }

  Future<void> _loadLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    phoneCtrl.text = prefs.getString('local_phone') ?? '';
    emailCtrl.text = prefs.getString('local_email') ?? emailCtrl.text;
  }

  Future<void> _save() async {
    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('local_phone', phoneCtrl.text.trim());
    await prefs.setString('local_email', emailCtrl.text.trim());

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Saved")),
    );
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
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile"), centerTitle: true),
      body: Padding(
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
              )
            ],
          ),
          child: Column(
            children: [
              // GOOGLE PHOTO
              CircleAvatar(
                radius: 45,
                backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                child: user.photoURL == null
                    ? const Icon(Icons.person, size: 40)
                    : null,
              ),

              const SizedBox(height: 25),

              // ✅ GOOGLE NAME (READ ONLY – FIXED)
              TextField(
                controller: nameCtrl,
                enabled: false,
                style: const TextStyle(
                  color: Colors.black, // text color
                  fontWeight: FontWeight.w600,
                ),
                decoration: _input("Name", Icons.person).copyWith(
                  fillColor: Colors.grey.shade200, // background color
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Colors.black,
                  ),
                  labelStyle: const TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),


              const SizedBox(height: 14),

              // EMAIL (LOCAL EDITABLE)
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _input("Email", Icons.email),
              ),

              const SizedBox(height: 14),

              // PHONE (LOCAL EDITABLE)
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _input("Phone", Icons.phone),
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
