import 'package:flutter/material.dart';

import '../../../models/mess_admin_sample_data.dart';
import '../../../widgets/section_header.dart';

class BillingOverviewScreen extends StatefulWidget {
  const BillingOverviewScreen({super.key});

  @override
  State<BillingOverviewScreen> createState() => _BillingOverviewScreenState();
}

class _BillingOverviewScreenState extends State<BillingOverviewScreen> {
  bool editVegNonVeg = false;

  late final List<Map<String, String>> vegStudents;
  late final List<Map<String, String>> nonVegStudents;

  @override
  void initState() {
    super.initState();
    vegStudents = List<Map<String, String>>.from(
      MessAdminSampleData.vegStudents,
    ).map((m) => Map<String, String>.from(m)).toList();
    nonVegStudents = List<Map<String, String>>.from(
      MessAdminSampleData.nonVegStudents,
    ).map((m) => Map<String, String>.from(m)).toList();
  }

  int get vegTotal => vegStudents.length;
  int get nonVegTotal => nonVegStudents.length;
  int get totalCost =>
      (vegTotal * MessAdminSampleData.vegPrice) +
      (nonVegTotal * MessAdminSampleData.nonVegPrice);

  Widget _card({required Widget child}) {
    const borderRadius = BorderRadius.all(Radius.circular(16));
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  Widget _billRow({
    required IconData icon,
    required String label,
    required String calcText,
    required String amountText,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                calcText,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Text(
          amountText,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _studentBox({
    required String title,
    required List<Map<String, String>> students,
    required bool editable,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accentColor.withOpacity(0.35), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_rounded, color: accentColor, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...students.asMap().entries.map((entry) {
            final i = entry.key;
            final s = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: editable
                        ? TextField(
                            controller: TextEditingController(
                              text: '${s['name']} (${s['room']})',
                            ),
                            onChanged: (v) {
                              final parts = v.split('(');
                              students[i]['name'] = parts[0].trim();
                              students[i]['room'] = parts.length > 1
                                  ? parts[1].replaceAll(')', '').trim()
                                  : '';
                            },
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: accentColor.withOpacity(0.4),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: accentColor),
                              ),
                            ),
                          )
                        : Text(
                            '${s['name']} (${s['room']})',
                            style: const TextStyle(fontSize: 12),
                          ),
                  ),
                  if (editable)
                    GestureDetector(
                      onTap: () => setState(() => students.removeAt(i)),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red.shade400,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
          if (editable)
            GestureDetector(
              onTap: () =>
                  setState(() => students.add({'name': 'New', 'room': '---'})),
              child: Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: accentColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Add',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(title: const Text('Billing Overview')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.receipt_long_rounded,
                title: 'Mess Bill',
                subtitle: 'Veg, Non-Veg & total calculation',
              ),
              const SizedBox(height: 8),
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _billRow(
                      icon: Icons.eco_rounded,
                      label: 'Veg',
                      calcText: '$vegTotal × ₹${MessAdminSampleData.vegPrice}',
                      amountText: '₹${vegTotal * MessAdminSampleData.vegPrice}',
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(height: 10),
                    _billRow(
                      icon: Icons.set_meal_rounded,
                      label: 'Non-Veg',
                      calcText:
                          '$nonVegTotal × ₹${MessAdminSampleData.nonVegPrice}',
                      amountText:
                          '₹${nonVegTotal * MessAdminSampleData.nonVegPrice}',
                      color: Colors.orange.shade700,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '₹$totalCost',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SectionHeader(
                icon: Icons.people_alt_rounded,
                title: 'Veg / Non-Veg Students',
                subtitle: 'Edit student lists (for calculation)',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container()),
                  FilledButton.tonal(
                    onPressed: () =>
                        setState(() => editVegNonVeg = !editVegNonVeg),
                    child: Text(editVegNonVeg ? 'Save' : 'Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _studentBox(
                      title: 'Veg',
                      students: vegStudents,
                      editable: editVegNonVeg,
                      accentColor: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _studentBox(
                      title: 'Non-Veg',
                      students: nonVegStudents,
                      editable: editVegNonVeg,
                      accentColor: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
