import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../student_data.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);
const _kGreen     = Color(0xFF2E7D32);
const _kGreenBg   = Color(0xFFE8F5E9);
const _kGreenBdr  = Color(0xFFA5D6A7);

class StudentPaymentPage extends StatefulWidget {
  const StudentPaymentPage({super.key});

  @override
  State<StudentPaymentPage> createState() => _StudentPaymentPageState();
}

class _StudentPaymentPageState extends State<StudentPaymentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back + title
                    Row(
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
                            child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size : 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Payments',
                                style: TextStyle(
                                    color        : Colors.white,
                                    fontSize     : 20,
                                    fontWeight   : FontWeight.w800,
                                    letterSpacing: -0.3)),
                            SizedBox(height: 2),
                            Text('View your HDF & Rent payment history',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tabs
                    TabBar(
                      controller           : _tab,
                      indicatorColor       : Colors.white,
                      indicatorWeight      : 3,
                      labelStyle           : const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 13),
                      unselectedLabelStyle : const TextStyle(
                          fontWeight: FontWeight.w500),
                      labelColor           : Colors.white,
                      unselectedLabelColor : Colors.white60,
                      tabs: const [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 15),
                              SizedBox(width: 6),
                              Text('HDF'),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 15),
                              SizedBox(width: 6),
                              Text('Rent'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Tab body ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tab,
              children  : [
                _PaymentList(type: _PayType.hdf),
                _PaymentList(type: _PayType.rent),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Payment type enum ─────────────────────────────────────────────────────────
enum _PayType { hdf, rent }

// ── Payment list ──────────────────────────────────────────────────────────────
class _PaymentList extends StatelessWidget {
  final _PayType type;

  const _PaymentList({required this.type});

  String get _field     => type == _PayType.hdf ? 'hdfPaid' : 'rentPaid';
  String get _typeLabel => type == _PayType.hdf ? 'HDF'     : 'Rent';
  IconData get _icon    => type == _PayType.hdf
      ? Icons.receipt_long_rounded
      : Icons.home_rounded;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(StudentData.admissionNo)
          .collection('budgets')
          .where(_field, isEqualTo: true)   // only paid months
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: _kBlue));
        }

        final docs = snap.data?.docs ?? [];

        // Sort by year desc then month desc (newest first)
        final sorted = [...docs];
        sorted.sort((a, b) {
          final da = a.data() as Map<String, dynamic>;
          final db = b.data() as Map<String, dynamic>;
          final yearA  = (da['year']  ?? 0) as int;
          final yearB  = (db['year']  ?? 0) as int;
          final monthA = _monthNum(da['month'] ?? '');
          final monthB = _monthNum(db['month'] ?? '');
          if (yearB != yearA) return yearB.compareTo(yearA);
          return monthB.compareTo(monthA);
        });

        if (sorted.isEmpty) {
          return _EmptyState(typeLabel: _typeLabel, icon: _icon);
        }

        // Group by year
        final Map<int, List<QueryDocumentSnapshot>> grouped = {};
        for (final doc in sorted) {
          final data = doc.data() as Map<String, dynamic>;
          final year = (data['year'] ?? 0) as int;
          grouped.putIfAbsent(year, () => []).add(doc);
        }
        final years = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding    : const EdgeInsets.fromLTRB(20, 24, 20, 36),
          itemCount  : years.length + 1, // +1 for summary card
          itemBuilder: (_, i) {
            // Summary card at top
            if (i == 0) {
              return _SummaryCard(
                count    : sorted.length,
                typeLabel: _typeLabel,
                icon     : _icon,
              );
            }

            final year  = years[i - 1];
            final items = grouped[year]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Year header
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 8),
                  child  : Row(
                    children: [
                      Container(
                        padding   : const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color       : _kBlueTint,
                          borderRadius: BorderRadius.circular(8),
                          border      : Border.all(color: _kBorder),
                        ),
                        child: Text(
                          '$year',
                          style: const TextStyle(
                              fontSize  : 13,
                              fontWeight: FontWeight.w800,
                              color     : _kBlue),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${items.length} month${items.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                            fontSize: 12, color: _kSubtext),
                      ),
                    ],
                  ),
                ),

                // Month cards
                ...items.map((doc) {
                  final data  = doc.data() as Map<String, dynamic>;
                  final month = data['month'] ?? '';
                  final updAt = data['updatedAt'] as Timestamp?;
                  final dateStr = updAt != null
                      ? DateFormat('dd MMM yyyy')
                          .format(updAt.toDate())
                      : '';

                  return _MonthCard(
                    month    : month,
                    year     : year,
                    dateStr  : dateStr,
                    typeLabel: _typeLabel,
                    icon     : _icon,
                  );
                }),

                const SizedBox(height: 6),
              ],
            );
          },
        );
      },
    );
  }

  // Convert month name to number for sorting
  int _monthNum(String name) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December',
    ];
    return months.indexOf(name) + 1;
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final int      count;
  final String   typeLabel;
  final IconData icon;

  const _SummaryCard({
    required this.count,
    required this.typeLabel,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin    : const EdgeInsets.only(bottom: 20),
      padding   : const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient    : const LinearGradient(
          colors: [_kBlue, _kBlueLight],
          begin : Alignment.topLeft,
          end   : Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x301565C0),
              blurRadius: 14,
              offset    : Offset(0, 5)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width     : 52,
            height    : 52,
            decoration: BoxDecoration(
              color       : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count month${count == 1 ? '' : 's'} paid',
                  style: const TextStyle(
                      color     : Colors.white,
                      fontSize  : 20,
                      fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  '$typeLabel payment history',
                  style: const TextStyle(
                      color  : Colors.white70,
                      fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding   : const EdgeInsets.symmetric(
                horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color       : Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

// ── Month card ────────────────────────────────────────────────────────────────
class _MonthCard extends StatelessWidget {
  final String   month;
  final int      year;
  final String   dateStr;
  final String   typeLabel;
  final IconData icon;

  const _MonthCard({
    required this.month,
    required this.year,
    required this.dateStr,
    required this.typeLabel,
    required this.icon,
  });

  // Short month abbreviation
  String get _shortMonth {
    const map = {
      'January': 'JAN', 'February': 'FEB', 'March': 'MAR',
      'April': 'APR', 'May': 'MAY', 'June': 'JUN',
      'July': 'JUL', 'August': 'AUG', 'September': 'SEP',
      'October': 'OCT', 'November': 'NOV', 'December': 'DEC',
    };
    return map[month] ?? month.substring(0, 3).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin    : const EdgeInsets.only(bottom: 10),
      padding   : const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border      : Border.all(color: _kGreenBdr, width: 1.2),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0A1565C0),
              blurRadius: 8,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Month badge
          Container(
            width : 50,
            height: 50,
            decoration: BoxDecoration(
              color       : _kGreenBg,
              borderRadius: BorderRadius.circular(13),
              border      : Border.all(color: _kGreenBdr),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_shortMonth,
                      style: const TextStyle(
                          fontSize  : 11,
                          fontWeight: FontWeight.w800,
                          color     : _kGreen)),
                  Text('$year',
                      style: const TextStyle(
                          fontSize: 9,
                          color   : _kGreen)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Month name + paid label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$month $year',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize  : 14,
                      color     : _kText),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: _kGreen, size: 13),
                    const SizedBox(width: 4),
                    Text(
                      '$typeLabel Paid',
                      style: const TextStyle(
                          fontSize  : 12,
                          fontWeight: FontWeight.w600,
                          color     : _kGreen),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Date updated
          if (dateStr.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Updated',
                    style: TextStyle(
                        fontSize: 9, color: _kSubtext)),
                const SizedBox(height: 2),
                Text(dateStr,
                    style: const TextStyle(
                        fontSize  : 10,
                        fontWeight: FontWeight.w600,
                        color     : _kSubtext)),
              ],
            ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String   typeLabel;
  final IconData icon;

  const _EmptyState({required this.typeLabel, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children    : [
          Container(
            width     : 72,
            height    : 72,
            decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(22)),
            child: Icon(icon, color: _kBlue, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'No $typeLabel payments yet',
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize  : 15,
                color     : _kText),
          ),
          const SizedBox(height: 6),
          Text(
            'Your paid $typeLabel months will appear here',
            style: const TextStyle(
                color  : _kSubtext,
                fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}