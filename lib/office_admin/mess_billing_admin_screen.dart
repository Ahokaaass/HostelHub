import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/mess_bill_entry.dart';
import '../services/mess_bills_service.dart';
import '../services/pdf_service.dart';

class MessBillingAdminScreen extends StatefulWidget {
  const MessBillingAdminScreen({super.key});

  @override
  State<MessBillingAdminScreen> createState() => _MessBillingAdminScreenState();
}

class _MessBillingAdminScreenState extends State<MessBillingAdminScreen> {
  final MessBillsService _service = MessBillsService();
  final PdfService _pdfService = const PdfService();

  String? _selectedDocId;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF5F8FF);
    const kBlue = Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(title: const Text('Mess Billing Admin')),
      body: SafeArea(
        child: StreamBuilder<List<MessBillEntry>>(
          stream: _service.streamMessBills(limit: 100),
          builder: (context, snapshot) {
            final entries = snapshot.data ?? const <MessBillEntry>[];

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (entries.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No mess bills found.',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            final availableMonths = entries
                .map((e) => e.month)
                .where((m) => m.isNotEmpty)
                .toSet()
                .toList();

            final selectedDocId = _selectedDocId ?? entries.first.docId;
            final selected = entries.firstWhere(
              (e) => e.docId == selectedDocId,
              orElse: () => entries.first,
            );
            final effectiveSelectedDocId = selected.docId;

            // Preserve current selection if still valid; otherwise fall back.
            final selectedMonth = selected.month;
            final monthsSorted = availableMonths.isEmpty
                ? <String>[selectedMonth]
                : (availableMonths..sort((a, b) => b.compareTo(a)));

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue:
                            selectedMonth.isNotEmpty &&
                                monthsSorted.contains(selectedMonth)
                            ? selectedMonth
                            : monthsSorted.first,
                        items: monthsSorted
                            .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)),
                            )
                            .toList(),
                        onChanged: (month) {
                          if (month == null) return;
                          final doc = entries.firstWhere(
                            (e) => e.month == month,
                            orElse: () => entries.first,
                          );
                          setState(() => _selectedDocId = doc.docId);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Select month',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status: ${_statusLabel(selected.status)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  if (selected.finalizedAt != null)
                                    const SizedBox(height: 4),
                                  if (selected.finalizedAt != null)
                                    Text(
                                      'Finalized: ${_formatDate(selected.finalizedAt!)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Color(0xFF6B7280),
                                      ),
                                    ),
                                ],
                              ),
                              _StatusChip(
                                status: selected.status,
                                kBlue: kBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _BillCards(
                        month: selected.month,
                        messBill: selected.messBill,
                        commonBill: selected.commonBill,
                        finalBill: selected.finalBill,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              final bytes = await _pdfService
                                  .generateMessBillPdf(
                                    PdfMessBillData(
                                      studentName: selected.studentName.isEmpty
                                          ? 'N/A'
                                          : selected.studentName,
                                      month: selected.month,
                                      breakfastCount: selected.breakfastCount,
                                      lunchCount: selected.lunchCount,
                                      dinnerCount: selected.dinnerCount,
                                      totalAmount: selected.finalBill,
                                    ),
                                  );
                              await Printing.sharePdf(
                                bytes: bytes,
                                filename:
                                    'mess_bill_${selected.month.replaceAll(' ', '_')}.pdf',
                              );
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to generate PDF: $e'),
                                  backgroundColor: Colors.red.shade600,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download_rounded),
                          label: const Text('Download PDF'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (selected.status.toLowerCase() != 'final')
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Finalize bill?'),
                                  content: const Text(
                                    'This will mark the selected bill as final.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text('Finalize'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed != true) return;
                              try {
                                await _service.finalizeBill(selected.docId);
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Bill finalized successfully',
                                    ),
                                  ),
                                );
                              } catch (e) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to finalize: $e'),
                                    backgroundColor: Colors.red.shade600,
                                  ),
                                );
                              }
                            },
                            child: const Text('Finalize Bill'),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: const Center(
                            child: Text(
                              'This bill is already final.',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1B5E20),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _HistoryList(
                    entries: entries,
                    selectedDocId: effectiveSelectedDocId,
                    onSelect: (docId) {
                      setState(() => _selectedDocId = docId);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    final s = status.toLowerCase();
    if (s == 'final') return 'Final';
    return 'Draft';
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/'
      '${dt.month.toString().padLeft(2, '0')}/'
      '${dt.year}';
}

class _StatusChip extends StatelessWidget {
  final String status;
  final Color kBlue;

  const _StatusChip({required this.status, required this.kBlue});

  @override
  Widget build(BuildContext context) {
    final isFinal = status.toLowerCase() == 'final';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isFinal ? Colors.green.shade50 : const Color(0xFFE8F0FE),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFinal ? Colors.green.shade200 : const Color(0xFFBBD0F8),
        ),
      ),
      child: Text(
        isFinal ? 'Final' : 'Draft',
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: isFinal ? Colors.green.shade700 : kBlue,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _BillCards extends StatelessWidget {
  final String month;
  final num messBill;
  final num commonBill;
  final num finalBill;

  const _BillCards({
    required this.month,
    required this.messBill,
    required this.commonBill,
    required this.finalBill,
  });

  String _money(num n) => n.toStringAsFixed(2).replaceAll('.00', '');

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BillCard(
          icon: Icons.restaurant_menu_rounded,
          title: 'Mess Bill',
          amount: '₹${_money(messBill)}',
          accent: Colors.blue.shade600,
        ),
        const SizedBox(height: 10),
        _BillCard(
          icon: Icons.people_alt_rounded,
          title: 'Common Bill',
          amount: '₹${_money(commonBill)}',
          accent: Colors.purple.shade700,
        ),
        const SizedBox(height: 10),
        _BillCard(
          icon: Icons.receipt_long_rounded,
          title: 'Final Bill',
          amount: '₹${_money(finalBill)}',
          accent: Colors.green.shade700,
          isTotal: true,
        ),
      ],
    );
  }
}

class _BillCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String amount;
  final Color accent;
  final bool isTotal;

  const _BillCard({
    required this.icon,
    required this.title,
    required this.amount,
    required this.accent,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withOpacity(0.20)),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1A1A2E),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    amount,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: accent,
                      fontSize: isTotal ? 18 : 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<MessBillEntry> entries;
  final String selectedDocId;
  final void Function(String docId) onSelect;

  const _HistoryList({
    required this.entries,
    required this.selectedDocId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final e = entries[i];
        final isSelected = e.docId == selectedDocId;
        final isFinal = e.status.toLowerCase() == 'final';
        return InkWell(
          onTap: () => onSelect(e.docId),
          borderRadius: BorderRadius.circular(16),
          child: Card(
            elevation: isSelected ? 4 : 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: isSelected
                  ? BorderSide(color: Colors.green.shade400, width: 1.5)
                  : BorderSide(color: Colors.transparent, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isFinal
                          ? Colors.green.shade50
                          : const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isFinal
                            ? Colors.green.shade200
                            : const Color(0xFFBBD0F8),
                      ),
                    ),
                    child: Icon(
                      isFinal
                          ? Icons.check_circle_rounded
                          : Icons.edit_note_rounded,
                      color: isFinal
                          ? Colors.green.shade700
                          : const Color(0xFF1565C0),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.month,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Final: ₹${e.finalBill.toStringAsFixed(2).replaceAll('.00', '')}',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: e.finalBill > 0
                                ? (isFinal
                                      ? Colors.green.shade700
                                      : const Color(0xFF1565C0))
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isFinal ? 'Final' : 'Draft',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: isFinal
                          ? Colors.green.shade700
                          : const Color(0xFF1565C0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
