import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/session.dart';
import '../../../services/purchases_service.dart';
import '../../../widgets/section_header.dart';

class PurchaseEntryScreen extends StatefulWidget {
  const PurchaseEntryScreen({super.key});

  @override
  State<PurchaseEntryScreen> createState() => _PurchaseEntryScreenState();
}

class _PurchaseEntryScreenState extends State<PurchaseEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  final _itemC = TextEditingController();
  final _qtyC = TextEditingController();
  final _priceC = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  final PurchasesService _service = PurchasesService();

  @override
  void dispose() {
    _itemC.dispose();
    _qtyC.dispose();
    _priceC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final v = _formKey.currentState?.validate();
    if (v != true) return;

    final addedBy = Session.userId;
    if (addedBy == null || addedBy.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User not available. Please login again.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final itemName = _itemC.text.trim();
      final quantity = double.parse(_qtyC.text.trim());
      final price = double.parse(_priceC.text.trim());

      await _service.addPurchase(
        itemName: itemName,
        quantity: quantity,
        price: price,
        date: _selectedDate,
        addedBy: addedBy,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase added successfully.')),
      );

      _formKey.currentState?.reset();
      _itemC.clear();
      _qtyC.clear();
      _priceC.clear();
      setState(() => _selectedDate = DateTime.now());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add purchase: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FF);
    const kBlue = Color(0xFF1565C0);
    const kBlueTint = Color(0xFFE8F0FE);
    const kBorder = Color(0xFFBBD0F8);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Add Purchase')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.inventory_2_outlined,
                title: 'Procured / Purchase Entry',
                subtitle: 'Add items purchased by the mess',
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _itemC,
                          decoration: InputDecoration(
                            labelText: 'Item name',
                            prefixIcon: const Icon(Icons.fastfood_rounded),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: kBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: kBlue,
                                width: 1.5,
                              ),
                            ),
                          ),
                          validator: (v) {
                            final s = v?.trim() ?? '';
                            if (s.isEmpty) return 'Item name is required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _qtyC,
                                decoration: InputDecoration(
                                  labelText: 'Quantity',
                                  prefixIcon: const Icon(Icons.storage_rounded),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: kBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: kBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.isEmpty) return 'Quantity is required';
                                  final n = num.tryParse(s);
                                  if (n == null) return 'Enter a valid number';
                                  if (n <= 0) {
                                    return 'Quantity must be greater than 0';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _priceC,
                                decoration: InputDecoration(
                                  labelText: 'Price',
                                  prefixIcon: const Icon(
                                    Icons.attach_money_rounded,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: kBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: kBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                validator: (v) {
                                  final s = v?.trim() ?? '';
                                  if (s.isEmpty) return 'Price is required';
                                  final n = num.tryParse(s);
                                  if (n == null) return 'Enter a valid number';
                                  if (n <= 0) {
                                    return 'Price must be greater than 0';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _pickDate,
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 14,
                            ),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kBlueTint,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month_rounded,
                                  color: kBlue,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Date: ${_selectedDate.day.toString().padLeft(2, '0')}/'
                                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                                    '${_selectedDate.year}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                                const Icon(
                                  Icons.edit_calendar_rounded,
                                  color: kBlue,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton.icon(
                            onPressed: _submitting ? null : _submit,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                              _submitting ? 'Saving...' : 'Add Purchase',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SectionHeader(
                icon: Icons.history_rounded,
                title: 'Recent Purchases',
                subtitle: 'Latest entries from the purchases collection',
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 320,
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.streamPurchases(limit: 5),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No purchases found.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: docs.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final d = docs[i].data();
                        final itemName = d['itemName']?.toString() ?? '';
                        final qty = d['quantity'] is num
                            ? d['quantity'] as num
                            : null;
                        final price = d['price'] is num
                            ? d['price'] as num
                            : null;
                        final total = d['total'] is num
                            ? d['total'] as num
                            : null;
                        final ts = d['date'] as Timestamp?;
                        final date = ts?.toDate();
                        final dateText = date == null
                            ? '—'
                            : '${date.day.toString().padLeft(2, '0')}/'
                                  '${date.month.toString().padLeft(2, '0')}/'
                                  '${date.year}';

                        final qtyText = qty == null ? '—' : qty.toString();
                        final priceText = price == null
                            ? '—'
                            : price.toString();
                        final totalText = total == null
                            ? '—'
                            : total.toString();

                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            itemName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            'Qty: $qtyText • Price: ₹$priceText • $dateText',
                          ),
                          trailing: Text(
                            '₹$totalText',
                            style: const TextStyle(fontWeight: FontWeight.w900),
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
      ),
    );
  }
}
