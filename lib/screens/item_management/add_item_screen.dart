// import 'package:flutter/material.dart';
//
// class AddItemScreen extends StatefulWidget {
//   final List products;
//   final VoidCallback refresh;
//
//   const AddItemScreen(this.products, this.refresh, {super.key});
//
//   @override
//   State<AddItemScreen> createState() => _AddItemScreenState();
// }
//
// class _AddItemScreenState extends State<AddItemScreen> {
//   final TextEditingController controller = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Item"),
//         backgroundColor: const Color(0xFF6A11CB),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             TextField(
//               controller: controller,
//               decoration: const InputDecoration(
//                 labelText: "Item Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF6A11CB),
//               ),
//               onPressed: () {
//                 if (controller.text.isNotEmpty) {
//                   widget.products.add({
//                     "name": controller.text.trim(),
//                     "stock": 0,
//                   });
//                   widget.refresh();
//                   Navigator.pop(context);
//                 }
//               },
//               child: const Text("Add Item"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _stockCtrl = TextEditingController(text: '0');
  bool _isLoading = false;

  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameCtrl.text.trim();
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    try {
      await itemsRef.add({
        'name': name,
        'stock': stock,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Item added')));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          elevation: 0,
          automaticallyImplyLeading: true,
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ITEM NAME INPUT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    hintText: "Item Name",
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Enter item name" : null,
                ),
              ),

              const SizedBox(height: 16),

              // STOCK INPUT
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextFormField(
                  controller: _stockCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "Initial Stock (0 by default)",
                    border: InputBorder.none,
                  ),
                  validator: (v) =>
                  (v == null || v.trim().isEmpty) ? "Enter stock value" : null,
                ),
              ),

              const SizedBox(height: 25),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                  onTap: _saveItem,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF6A5AE0),
                          Color(0xFF8A7FFD),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.purpleAccent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Save Item",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}

