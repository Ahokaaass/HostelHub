import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../services/purchases_service.dart';
import '../services/pdf_service.dart';

class PurchasesAdminListScreen extends StatefulWidget {
  const PurchasesAdminListScreen({super.key});

  @override
  State<PurchasesAdminListScreen> createState() =>
      _PurchasesAdminListScreenState();
}

class _PurchasesAdminListScreenState extends State<PurchasesAdminListScreen> {
  final PurchasesService _service = PurchasesService();
  final PdfService _pdfService = const PdfService();

  final _scrollController = ScrollController();

  DateTime? _start;
  DateTime? _end;
  bool _groupByDay = false;

  Future<void> _pickStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _start ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _start = picked);
  }

  Future<void> _pickEnd() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _end ?? (_start ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _end = picked);
  }

  void _clearFilter() {
    setState(() {
      _start = null;
      _end = null;
    });
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  DateTime _dayKey(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  Future<void> _downloadPurchasePdf(List<_PurchaseRow> purchases) async {
    try {
      final pdfData = PdfPurchaseData(
        date: DateTime.now(),
        items: purchases
            .map(
              (p) => PdfPurchaseItem(
                itemName: p.itemName.isEmpty ? 'Unknown item' : p.itemName,
                quantity: p.quantity,
                unit: p.unit,
                price: p.price,
                total: p.total,
              ),
            )
            .toList(),
      );
      final bytes = await _pdfService.generatePurchasePdf(pdfData);
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'purchased_items_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FF);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Purchases (Admin)')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      FilledButton.tonal(
                        onPressed: _pickStart,
                        child: Text(
                          _start == null
                              ? 'Pick start date'
                              : 'From: ${_formatDate(_start!)}',
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: _pickEnd,
                        child: Text(
                          _end == null
                              ? 'Pick end date'
                              : 'To: ${_formatDate(_end!)}',
                        ),
                      ),
                      OutlinedButton(
                        onPressed: _clearFilter,
                        child: const Text('Clear filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _groupByDay,
                    onChanged: (v) => setState(() => _groupByDay = v),
                    title: const Text(
                      'Group purchases by day',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _service.streamPurchases(start: _start, end: _end),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];
                  num sum = 0;
                  for (final d in docs) {
                    final total = d.data()['total'];
                    if (total is num) sum += total;
                  }

                  // Convert and display; list is already latest-first due to query ordering.
                  final purchases = docs.map((d) {
                    final data = d.data();
                    final dateTs = data['date'] as Timestamp?;
                    final date = dateTs?.toDate();
                    return _PurchaseRow(
                      itemName: data['itemName']?.toString() ?? '',
                      quantity: data['quantity'] is num
                          ? (data['quantity'] as num)
                          : 0,
                      unit: data['unit']?.toString() ?? '-',
                      price: data['price'] is num ? (data['price'] as num) : 0,
                      total: data['total'] is num ? (data['total'] as num) : 0,
                      date: date,
                    );
                  }).toList();

                  final totalCard = Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total expenditure',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '₹${sum.toStringAsFixed(2).replaceAll('.00', '')}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 20,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          totalCard,
                          const SizedBox(height: 12),
                          Expanded(
                            child: const Center(
                              child: Text(
                                'No purchases found for the selected filter.',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!_groupByDay) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            children: [
                              totalCard,
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _downloadPurchasePdf(purchases),
                                  icon: const Icon(Icons.download_rounded),
                                  label: const Text('Download PDF'),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            itemCount: purchases.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              return _PurchaseCard(purchase: purchases[i]);
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  final Map<DateTime, List<_PurchaseRow>> grouped = {};
                  for (final p in purchases) {
                    final key = p.date == null
                        ? DateTime(1970)
                        : _dayKey(p.date!);
                    grouped.putIfAbsent(key, () => []).add(p);
                  }

                  final groupedKeys = grouped.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        child: Column(
                          children: [
                            totalCard,
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () =>
                                    _downloadPurchasePdf(purchases),
                                icon: const Icon(Icons.download_rounded),
                                label: const Text('Download PDF'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: groupedKeys.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, i) {
                            final day = groupedKeys[i];
                            final items = grouped[day] ?? const [];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Text(
                                      _formatDate(day),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        color: Color(0xFF1565C0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                ...items.map(
                                  (p) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _PurchaseCard(purchase: p),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PurchaseRow {
  final String itemName;
  final num quantity;
  final String unit;
  final num price;
  final num total;
  final DateTime? date;

  const _PurchaseRow({
    required this.itemName,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.total,
    required this.date,
  });
}

class _PurchaseCard extends StatelessWidget {
  final _PurchaseRow purchase;

  const _PurchaseCard({required this.purchase});

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';

  String _numText(num n) => n.toStringAsFixed(2).replaceAll('.00', '');

  @override
  Widget build(BuildContext context) {
    final dateText = purchase.date == null ? '—' : _formatDate(purchase.date!);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shopping_cart_rounded,
                  size: 18,
                  color: Color(0xFF1565C0),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    purchase.itemName.isEmpty
                        ? 'Unknown item'
                        : purchase.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Kv('Qty', '${_numText(purchase.quantity)} ${purchase.unit}'),
                const SizedBox(width: 12),
                Kv('Price', '₹${_numText(purchase.price)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: $dateText',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Total: ₹${_numText(purchase.total)}',
                  style: const TextStyle(
                    color: Color(0xFF1565C0),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Kv extends StatelessWidget {
  final String k;
  final String v;

  const Kv(this.k, this.v, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            k,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            v,
            style: const TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
