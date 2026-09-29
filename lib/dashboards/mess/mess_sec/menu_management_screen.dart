import 'package:flutter/material.dart';

import '../../../models/mess_admin_sample_data.dart';
import '../../../widgets/section_header.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  bool editMenu = false;

  late final List<Map<String, String>> menu;

  @override
  void initState() {
    super.initState();
    menu = MessAdminSampleData.weeklyMenu
        .map((m) => Map<String, String>.from(m))
        .toList();
  }

  Widget _card({required Widget child}) {
    const borderRadius = BorderRadius.all(Radius.circular(16));
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }

  TableRow _tableHeader(List<String> titles) => TableRow(
    decoration: const BoxDecoration(color: Color(0xFFE8F0FE)),
    children: titles
        .map(
          (t) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              t,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
        )
        .toList(),
  );

  TableRow _editableRow(Map<String, String> row) => TableRow(
    children: row.values.map((v) {
      final key = row.keys.elementAt(row.values.toList().indexOf(v));
      return Padding(
        padding: const EdgeInsets.all(6),
        child: editMenu
            ? TextField(
                controller: TextEditingController(text: v),
                onChanged: (val) => row[key] = val,
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: Color(0xFFBBD0F8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(
                      color: Color(0xFF1565C0),
                      width: 1.5,
                    ),
                  ),
                ),
              )
            : Text(v, style: const TextStyle(fontSize: 11)),
      );
    }).toList(),
  );

  Widget _menuTable() => ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBBD0F8)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Table(
        border: TableBorder(
          horizontalInside: const BorderSide(
            color: Color(0xFFBBD0F8),
            width: 0.8,
          ),
          verticalInside: const BorderSide(
            color: Color(0xFFBBD0F8),
            width: 0.8,
          ),
        ),
        columnWidths: const {
          0: FlexColumnWidth(1.2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.2),
          4: FlexColumnWidth(1.5),
        },
        children: [
          _tableHeader(['Day', 'Breakfast', 'Lunch', 'Snack', 'Dinner']),
          ...menu.map((m) => _editableRow(m)),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(title: const Text('Menu Management')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                icon: Icons.restaurant_menu_rounded,
                title: 'Weekly Menu',
                subtitle: 'Update breakfast, lunch, snack & dinner',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container()),
                  FilledButton.tonal(
                    onPressed: () => setState(() => editMenu = !editMenu),
                    child: Text(editMenu ? 'Save' : 'Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _card(child: _menuTable()),
            ],
          ),
        ),
      ),
    );
  }
}
