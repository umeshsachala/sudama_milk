import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StockInScreen extends StatefulWidget {
  const StockInScreen({super.key});

  @override
  State<StockInScreen> createState() => _StockInScreenState();
}

class _StockInScreenState extends State<StockInScreen> {
  final CollectionReference itemsRef =
  FirebaseFirestore.instance.collection('items');
  final CollectionReference txRef =
  FirebaseFirestore.instance.collection('stock_transactions');

  String? _selectedId;
  String? _selectedName;
  final TextEditingController _qtyCtrl = TextEditingController(text: '1');
  bool _isLoading = false;

  // Last added details
  String? lastItemName;
  int? lastQty;
  String? lastTime;

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

    final now = DateTime.now();
    final formattedTime =
        "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

    final tx = {
      'itemId': _selectedId,
      'itemName': _selectedName ?? '',
      'type': 'in',
      'qty': qty,
      'timestamp': FieldValue.serverTimestamp(),
    };

    try {
      await itemsRef.doc(_selectedId).update({
        'stock': FieldValue.increment(qty),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await txRef.add(tx);

      setState(() {
        lastItemName = _selectedName;
        lastQty = qty;
        lastTime = formattedTime;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Stock added')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentFormattedTime =
        "${now.day}/${now.month}/${now.year}  ${now.hour}:${now.minute.toString().padLeft(2, '0')}";

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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------
              // DROPDOWN
              // --------------------------------------------
              StreamBuilder<QuerySnapshot>(
                stream: itemsRef.orderBy('name').snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snap.data!.docs;

                  return Container(
                    width: double.infinity, // ✅ container width
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
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
                            child: Text(data['name']),
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

              // QTY FIELD
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

              SizedBox(
                width: double.infinity,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GestureDetector(
                  onTap: _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF43A047), // Dark Green
                          Color(0xFF66BB6A), // Light Green
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withOpacity(0.4),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        "Add Stock",
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
              ),
              const SizedBox(height: 12),

            ],
          ),
        ),
      ),
    );
  }
}
