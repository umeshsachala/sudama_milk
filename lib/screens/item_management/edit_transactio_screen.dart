import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  final user = FirebaseAuth.instance.currentUser!;
  late final CollectionReference itemsRef;

  static const Color mainGreen = Color(0xFF0B7D3B);

  @override
  void initState() {
    super.initState();

    qtyCtrl =
        TextEditingController(text: widget.txDoc['qty'].toString());

    itemsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('items');
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
      backgroundColor: const Color(0xFFF4F6F4),

      // ================= APP BAR (SOLID GREEN) =================
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: mainGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Edit Transaction",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),

      // ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------- ITEM CARD ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Item Name",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.txDoc['itemName'] ?? "Item",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ---------- QTY CARD ----------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Quantity",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _qtyButton(Icons.remove, _decQty),
                      Container(
                        width: 80,
                        margin:
                        const EdgeInsets.symmetric(horizontal: 16),
                        padding:
                        const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: mainGreen, width: 2),
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
                ],
              ),
            ),

            const Spacer(),

            // ---------- SAVE BUTTON ----------
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF37474F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _save,
                child: const Text(
                  "Save Changes",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: mainGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
