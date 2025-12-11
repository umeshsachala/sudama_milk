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
  final CollectionReference itemsRef = FirebaseFirestore.instance.collection('items');

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      appBar: AppBar(title: const Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Item name'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null),
                  const SizedBox(height: 12),
                  TextFormField(controller: _stockCtrl, decoration: const InputDecoration(labelText: 'Stock (number)'), keyboardType: TextInputType.number, validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter stock' : null),
                  const SizedBox(height: 20),
                  _isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: _saveItem, child: const Text('Save Item')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

