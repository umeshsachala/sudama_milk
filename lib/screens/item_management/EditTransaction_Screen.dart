import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  final String itemId;
  final DocumentSnapshot txDoc;

  const EditTransactionScreen({
    Key? key,
    required this.itemId,
    required this.txDoc,
  }) : super(key: key);

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late TextEditingController qtyCtrl;

  final itemsRef = FirebaseFirestore.instance.collection('items');

  @override
  void initState() {
    super.initState();
    qtyCtrl =
        TextEditingController(text: widget.txDoc['qty'].toString());
  }

  /// 🔴 LOGIC SAME – NOT TOUCHED
  Future<void> _save() async {
    final int oldQty = widget.txDoc['qty'];
    final int newQty = int.parse(qtyCtrl.text);
    final String type = widget.txDoc['type'];

    final int diff =
    type == 'in' ? newQty - oldQty : oldQty - newQty;

    await itemsRef.doc(widget.itemId).update({
      'stock': FieldValue.increment(diff),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await widget.txDoc.reference.update({
      'qty': newQty,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  void _incQty() {
    setState(() {
      qtyCtrl.text =
          (int.parse(qtyCtrl.text) + 1).toString();
    });
  }

  void _decQty() {
    final current = int.parse(qtyCtrl.text);
    if (current > 1) {
      setState(() {
        qtyCtrl.text = (current - 1).toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6F4),

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        title: const Text(
          "Edit",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _save,
          )
        ],
      ),

      // ---------------- BODY ----------------
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ITEM NAME (READ ONLY LOOK)
            const Text(
              "Item name",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade400),
                color: Colors.white,
              ),
              child: Text(
                widget.txDoc['itemName'] ?? "Item",
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            /// QUANTITY TITLE
            Text(
              "Quantity (${widget.txDoc['qty']})",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            /// QUANTITY CONTROLLER
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _qtyButton(Icons.remove, _decQty),
                Container(
                  width: 70,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.green.shade700, width: 2),
                  ),
                  child: Text(
                    qtyCtrl.text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _qtyButton(Icons.add, _incQty),
              ],
            ),

            const Spacer(),

            /// SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _save,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}