import 'package:flutter/material.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class OthersTabScreen extends StatefulWidget {
  const OthersTabScreen({super.key});

  @override
  State<OthersTabScreen> createState() => _OthersTabScreenState();
}

class _OthersTabScreenState extends State<OthersTabScreen> {

  // ── Edit toggles ──────────────────────────────────────────────────────────
  bool editVegNonVeg = false;
  bool editMenu      = false;
  bool editDuty      = false;

  // ── Veg / Non-Veg ────────────────────────────────────────────────────────
  List<Map<String, String>> vegStudents = [
    {'name': 'Nanditha', 'room': '2115'},
    {'name': 'Aisha',    'room': '2112'},
    {'name': 'Priya',    'room': '2006'},
    {'name': 'Sneha',    'room': '2114'},
  ];

  List<Map<String, String>> nonVegStudents = [
    {'name': 'Revathy', 'room': '2107'},
    {'name': 'Anika',   'room': '2108'},
    {'name': 'Nashva',  'room': '2109'},
  ];

  // ── Menu ─────────────────────────────────────────────────────────────────
  List<Map<String, String>> menu = [
    {'day': 'Monday',    'breakfast': 'Idli + Sambar',  'lunch': 'Rice + Dal',     'snack': 'Pazham',       'dinner': 'Chapati + Curry'},
    {'day': 'Tuesday',   'breakfast': 'Dosa',           'lunch': 'Rice + Sambar',  'snack': 'Tea + Biscuit','dinner': 'Puttu + Kadala'},
    {'day': 'Wednesday', 'breakfast': 'Idiyappam',      'lunch': 'Rice + Rasam',   'snack': 'Pazham',       'dinner': 'Chapati'},
    {'day': 'Thursday',  'breakfast': 'Upma',           'lunch': 'Rice + Dal',     'snack': 'Tea',          'dinner': 'Fried Rice'},
    {'day': 'Friday',    'breakfast': 'Poori',          'lunch': 'Veg Biriyani',   'snack': 'Biscuit',      'dinner': 'Chapati'},
    {'day': 'Saturday',  'breakfast': 'Dosa',           'lunch': 'Rice + Curry',   'snack': 'Tea',          'dinner': 'Noodles'},
    {'day': 'Sunday',    'breakfast': 'Idli',           'lunch': 'Special Meals',  'snack': 'Juice',        'dinner': 'Chapati'},
  ];

  // ── Duty ─────────────────────────────────────────────────────────────────
  List<Map<String, String>> duty = [
    {'date': '02/01/26', 'evening': '2108', 'night': '2109'},
    {'date': '02/02/26', 'evening': '2110', 'night': '2111'},
    {'date': '02/03/26', 'evening': '2112', 'night': '2113'},
    {'date': '02/04/26', 'evening': '2114', 'night': '2115'},
    {'date': '02/05/26', 'evening': '2116', 'night': '2117'},
    {'date': '02/06/26', 'evening': '2118', 'night': '2119'},
    {'date': '02/07/26', 'evening': '2120', 'night': '2121'},
    {'date': '02/08/26', 'evening': '2122', 'night': '2123'},
    {'date': '02/09/26', 'evening': '2124', 'night': '2125'},
    {'date': '02/10/26', 'evening': '2126', 'night': '2127'},
    {'date': '02/11/26', 'evening': '2128', 'night': '2129'},
    {'date': '02/12/26', 'evening': '2130', 'night': '2131'},
  ];

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final int vegTotal    = vegStudents.length;
    final int nonVegTotal = nonVegStudents.length;
    final int totalCost   = (vegTotal * 90) + (nonVegTotal * 110);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color     : Color(0x351565C0),
                  blurRadius: 18,
                  offset    : Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Others',
                            style: TextStyle(
                                color        : Colors.white,
                                fontSize     : 20,
                                fontWeight   : FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Mess bill, menu & duty',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Mess Bill ──────────────────────────────────────────
                  _sectionHeader(Icons.receipt_long_rounded, 'Mess Bill'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _billRow(Icons.eco_rounded,
                            'Veg', '$vegTotal × ₹90',
                            '₹${vegTotal * 90}',
                            Colors.green.shade600),
                        const SizedBox(height: 10),
                        _billRow(Icons.set_meal_rounded,
                            'Non-Veg', '$nonVegTotal × ₹110',
                            '₹${nonVegTotal * 110}',
                            Colors.orange.shade600),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, color: _kBorder),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize  : 15,
                                    color     : _kText)),
                            Text('₹$totalCost',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize  : 16,
                                    color     : _kBlue)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Veg / Non-Veg ──────────────────────────────────────
                  _sectionHeaderWithEdit(
                    Icons.people_alt_rounded,
                    'Veg / Non-Veg Students',
                    editVegNonVeg,
                    () => setState(() => editVegNonVeg = !editVegNonVeg),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _studentBox(
                              'Veg',
                              vegStudents,
                              editVegNonVeg,
                              Colors.green.shade600,
                              Colors.green.shade50)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _studentBox(
                              'Non-Veg',
                              nonVegStudents,
                              editVegNonVeg,
                              Colors.orange.shade600,
                              Colors.orange.shade50)),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Menu ───────────────────────────────────────────────
                  _sectionHeaderWithEdit(
                    Icons.restaurant_menu_rounded,
                    'Weekly Menu',
                    editMenu,
                    () => setState(() => editMenu = !editMenu),
                  ),
                  const SizedBox(height: 12),
                  _menuTable(),

                  const SizedBox(height: 28),

                  // ── Duty ───────────────────────────────────────────────
                  _sectionHeaderWithEdit(
                    Icons.calendar_today_rounded,
                    'Duty Allocation',
                    editDuty,
                    () => setState(() => editDuty = !editDuty),
                  ),
                  const SizedBox(height: 12),
                  _dutyTable(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bill row ───────────────────────────────────────────────────────────────
  Widget _billRow(IconData icon, String label, String calc,
      String amount, Color color) =>
      Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
              color       : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize  : 13,
                        color     : _kText)),
                Text(calc,
                    style: const TextStyle(
                        fontSize: 11, color: _kSubtext)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 14,
                  color     : color)),
        ],
      );

  // ── Student box ───────────────────────────────────────────────────────────
  Widget _studentBox(
    String title,
    List<Map<String, String>> students,
    bool editable,
    Color accentColor,
    Color bgColor,
  ) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color       : bgColor,
          borderRadius: BorderRadius.circular(14),
          border      : Border.all(
              color: accentColor.withOpacity(0.3), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width : 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color       : accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: accentColor, size: 14),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 13,
                        color     : accentColor)),
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
                                  text:
                                      '${s['name']} (${s['room']})'),
                              onChanged: (v) {
                                final parts = v.split('(');
                                students[i]['name'] =
                                    parts[0].trim();
                                students[i]['room'] =
                                    parts.length > 1
                                        ? parts[1]
                                            .replaceAll(')', '')
                                            .trim()
                                        : '';
                              },
                              style: const TextStyle(
                                  fontSize: 12, color: _kText),
                              decoration: InputDecoration(
                                isDense      : true,
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical  : 6),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: accentColor
                                          .withOpacity(0.4)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                      color: accentColor),
                                ),
                              ),
                            )
                          : Text(
                              '${s['name']} (${s['room']})',
                              style: const TextStyle(
                                  fontSize: 12, color: _kText),
                            ),
                    ),
                    if (editable)
                      GestureDetector(
                        onTap: () =>
                            setState(() => students.removeAt(i)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(Icons.remove_circle_outline,
                              color: Colors.red.shade400, size: 16),
                        ),
                      ),
                  ],
                ),
              );
            }),
            if (editable)
              GestureDetector(
                onTap: () => setState(() =>
                    students.add({'name': 'New', 'room': '---'})),
                child: Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color       : accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: accentColor, size: 14),
                      const SizedBox(width: 4),
                      Text('Add',
                          style: TextStyle(
                              color    : accentColor,
                              fontSize : 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );

  // ── Menu table ────────────────────────────────────────────────────────────
  Widget _menuTable() => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border      : Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Table(
            border: TableBorder(
              horizontalInside:
                  const BorderSide(color: _kBorder, width: 0.8),
              verticalInside:
                  const BorderSide(color: _kBorder, width: 0.8),
            ),
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.5),
            },
            children: [
              _tableHeader(
                  ['Day', 'Breakfast', 'Lunch', 'Snack', 'Dinner']),
              ...menu.map((m) => _editableRow(m, editMenu)),
            ],
          ),
        ),
      );

  // ── Duty table ────────────────────────────────────────────────────────────
  Widget _dutyTable() => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Container(
          decoration: BoxDecoration(
            border      : Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Table(
            border: TableBorder(
              horizontalInside:
                  const BorderSide(color: _kBorder, width: 0.8),
              verticalInside:
                  const BorderSide(color: _kBorder, width: 0.8),
            ),
            children: [
              _tableHeader(['Date', 'Evening Room', 'Night Room']),
              ...duty.map((d) => _editableRow(d, editDuty)),
            ],
          ),
        ),
      );

  // ── Helpers ───────────────────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 12,
                offset    : Offset(0, 4)),
          ],
        ),
        child: child,
      );

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _kBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize     : 16,
                  fontWeight   : FontWeight.w800,
                  color        : _kText,
                  letterSpacing: -0.2)),
        ],
      );

  Widget _sectionHeaderWithEdit(
    IconData icon,
    String title,
    bool editing,
    VoidCallback onTap,
  ) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _sectionHeader(icon, title),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: editing ? Colors.green.shade600 : _kBlueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    editing
                        ? Icons.check_rounded
                        : Icons.edit_rounded,
                    color: editing ? Colors.white : _kBlue,
                    size : 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    editing ? 'Save' : 'Edit',
                    style: TextStyle(
                        color    : editing ? Colors.white : _kBlue,
                        fontSize : 12,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      );

  TableRow _tableHeader(List<String> titles) => TableRow(
        decoration: const BoxDecoration(color: _kBlueTint),
        children: titles
            .map((t) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(t,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 11,
                          color     : _kBlue)),
                ))
            .toList(),
      );

  TableRow _editableRow(Map<String, String> row, bool editable) =>
      TableRow(
        children: row.values.map((v) {
          final key = row.keys
              .elementAt(row.values.toList().indexOf(v));
          return Padding(
            padding: const EdgeInsets.all(6),
            child: editable
                ? TextField(
                    controller:
                        TextEditingController(text: v),
                    onChanged: (val) => row[key] = val,
                    style: const TextStyle(
                        fontSize: 11, color: _kText),
                    decoration: InputDecoration(
                      isDense      : true,
                      contentPadding:
                          const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 6),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: _kBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(6),
                        borderSide: const BorderSide(
                            color: _kBlue, width: 1.5),
                      ),
                    ),
                  )
                : Text(v,
                    style: const TextStyle(
                        fontSize: 11, color: _kText)),
          );
        }).toList(),
      );
}