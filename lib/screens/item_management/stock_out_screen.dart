// import 'package:flutter/material.dart';
//
// class StockOutScreen extends StatefulWidget {
//   final List products;
//   final VoidCallback refresh;
//
//   const StockOutScreen(this.products, this.refresh, {super.key});
//
//   @override
//   State<StockOutScreen> createState() => _StockOutScreenState();
// }
//
// class _StockOutScreenState extends State<StockOutScreen> {
//   String? selectedItem;
//   final TextEditingController qtyController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Stock Out"), backgroundColor: const Color(0xFF6A11CB)),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             DropdownButtonFormField(
//               decoration: const InputDecoration(border: OutlineInputBorder()),
//               value: selectedItem,
//               hint: const Text("Select Item"),
//               items: widget.products.map((item) {
//                 return DropdownMenuItem(
//                   value: item["name"],
//                   child: Text(item["name"]),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() => selectedItem = value as String?);
//               },
//             ),
//
//             const SizedBox(height: 20),
//
//             TextField(
//               controller: qtyController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: "Quantity",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB)),
//               onPressed: () {
//                 if (selectedItem != null && qtyController.text.isNotEmpty) {
//                   int qty = int.parse(qtyController.text);
//                   var product = widget.products.firstWhere((p) => p["name"] == selectedItem);
//
//                   if (product["stock"] >= qty) {
//                     product["stock"] -= qty;
//                     widget.refresh();
//                     Navigator.pop(context);
//                   } else {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Not enough stock")),
//                     );
//                   }
//                 }
//               },
//               child: const Text("Reduce Stock"),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockOutScreen extends StatefulWidget {
  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');
  final CollectionReference txRef =
  FirebaseFirestore.instance.collection('stock_transactions');

  String? _selectedId;
  String? _selectedName;
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  bool _isLoading = false;

  Future<void> _submit() async {
    if (_selectedId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Select item')));
      return;
    }

    final qty = int.tryParse(_qtyCtrl.text) ?? 0;
    if (qty <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter valid qty')));
      return;
    }

    setState(() => _isLoading = true);

    final docRef = itemsRef.doc(_selectedId);

    try {
      final snap = await docRef.get();
      final current = (snap.data() as Map<String, dynamic>)['stock'] ?? 0;
      final currentInt =
      (current is int) ? current : int.tryParse(current.toString()) ?? 0;

      if (currentInt < qty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Insufficient stock')));
        setState(() => _isLoading = false);
        return;
      }

      await docRef.update({
        'stock': FieldValue.increment(-qty),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await txRef.add({
        'itemId': _selectedId,
        'itemName': _selectedName ?? '',
        'type': 'out',
        'qty': qty,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Stock removed')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: const [
            SizedBox(width: 10),
            Text(
              "Sudama Milk",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),


      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ITEM DROPDOWN (MATCHING DESIGN)
            StreamBuilder<QuerySnapshot>(
              stream: itemsRef.orderBy('name').snapshots(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data!.docs;

                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedId,
                      hint: const Text("Select Item"),
                      items: docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        return DropdownMenuItem(
                          value: d.id,
                          child: Text(
                              "${data['name']} (Stock: ${data['stock'] ?? 0})"),
                        );
                      }).toList(),
                      onChanged: (v) {
                        final sel = docs.firstWhere((e) => e.id == v);
                        final data = sel.data() as Map<String, dynamic>;

                        setState(() {
                          _selectedId = v;
                          _selectedName = data['name'];
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // QTY FIELD (NO OUTLINE)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: "Enter Quantity",
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 25),

            // REMOVE BUTTON
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade700,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _submit,
                child: const Text(
                  "Remove Stock",
                  style: TextStyle(fontSize: 20,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
