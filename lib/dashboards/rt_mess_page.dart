import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class RtMessPage extends StatefulWidget {
  const RtMessPage({super.key});

  @override
  State<RtMessPage> createState() => _RtMessPageState();
}

class _RtMessPageState extends State<RtMessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        20, 14, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              Navigator.pop(context),
                          child: Container(
                            width : 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(0.18),
                              borderRadius:
                                  BorderRadius.circular(11),
                              border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.3)),
                            ),
                            child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size : 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Mess',
                                style: TextStyle(
                                    color        : Colors.white,
                                    fontSize     : 20,
                                    fontWeight   : FontWeight.w800,
                                    letterSpacing: -0.3)),
                            SizedBox(height: 2),
                            Text(
                                'Bill calculation & student bills',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // ── Tab bar inside header ─────────────────────────
                  const SizedBox(height: 16),
                  Container(
                    margin: const EdgeInsets.fromLTRB(
                        20, 0, 20, 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller      : _tabController,
                      indicator       : BoxDecoration(
                        color        : Colors.white,
                        borderRadius : BorderRadius.circular(10),
                      ),
                      indicatorSize   : TabBarIndicatorSize.tab,
                      labelColor      : _kBlue,
                      unselectedLabelColor: Colors.white,
                      labelStyle      : const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 13),
                      unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize  : 13),
                      padding: const EdgeInsets.all(4),
                      tabs: const [
                        Tab(text: 'Bill Calculation'),
                        Tab(text: 'Student Bills'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Tab views ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                _BillCalculationTab(),
                _StudentBillsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — MESS BILL CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
class _BillCalculationTab extends StatelessWidget {
  const _BillCalculationTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // reads from mess_bill collection — same as principal & admin
      stream: FirebaseFirestore.instance
          .collection('mess_bill')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        // ── derive values, fall back to 0 if no data yet ───────────
        int    vegCount    = 0;
        int    nonVegCount = 0;
        double vegRate     = 90;
        double nonVegRate  = 110;

        if (snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          final d = snapshot.data!.docs.first.data()
              as Map<String, dynamic>;
          vegCount    =
              (d['vegCount']    as num?)?.toInt()    ?? 0;
          nonVegCount =
              (d['nonVegCount'] as num?)?.toInt()    ?? 0;
          vegRate     =
              (d['vegRate']     as num?)?.toDouble() ?? 90;
          nonVegRate  =
              (d['nonVegRate']  as num?)?.toDouble() ?? 110;
        }

        final int    totalStudents  = vegCount + nonVegCount;
        final double vegTotal       = vegCount * vegRate;
        final double nonVegTotal    = nonVegCount * nonVegRate;
        final double calculatedBill = vegTotal + nonVegTotal;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Overview banner ───────────────────────────────────
              Container(
                width  : double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin : Alignment.topLeft,
                    end   : Alignment.bottomRight,
                    colors: [_kBlue, _kBlueLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color     : Color(0x301565C0),
                      blurRadius: 14,
                      offset    : Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Calculated Bill',
                        style: TextStyle(
                            color  : Colors.white70,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${calculatedBill.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color     : Colors.white,
                          fontSize  : 32,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _bannerChip(
                            '$totalStudents',
                            'Total Students'),
                        const SizedBox(width: 10),
                        _bannerChip(
                            '$vegCount', 'Veg'),
                        const SizedBox(width: 10),
                        _bannerChip(
                            '$nonVegCount', 'Non-Veg'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _sectionHeader(
                  Icons.calculate_rounded,
                  'Bill Breakdown'),
              const SizedBox(height: 12),

              // ── Breakdown card ────────────────────────────────────
              _card(
                child: Column(
                  children: [
                    _calcRow(
                      icon  : Icons.eco_rounded,
                      label : 'Veg Students',
                      detail: '$vegCount × ₹${vegRate.toStringAsFixed(0)}/day',
                      amount: '₹${vegTotal.toStringAsFixed(2)}',
                      color : Colors.green.shade600,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                          height: 1, color: _kBorder),
                    ),
                    _calcRow(
                      icon  : Icons.set_meal_rounded,
                      label : 'Non-Veg Students',
                      detail:
                          '$nonVegCount × ₹${nonVegRate.toStringAsFixed(0)}/day',
                      amount:
                          '₹${nonVegTotal.toStringAsFixed(2)}',
                      color : Colors.orange.shade600,
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 10),
                      child: Divider(
                          height: 1, color: _kBorder),
                    ),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize  : 15,
                                color     : _kText)),
                        Text(
                          '₹${calculatedBill.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize  : 16,
                              color     : _kBlue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.info_outline_rounded,
                  'Formula & Rates'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: [
                    _infoRow('Veg Rate / day',
                        '₹${vegRate.toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Non-Veg Rate / day',
                        '₹${nonVegRate.toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow(
                      'Formula',
                      'Count × Rate per day',
                      valueColor: _kBlue,
                      isBold    : true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _bannerChip(String value, String label) =>
      Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color       : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color     : Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize  : 15)),
            Text(label,
                style: const TextStyle(
                    color  : Colors.white70,
                    fontSize: 10)),
          ],
        ),
      );

  Widget _calcRow({
    required IconData icon,
    required String   label,
    required String   detail,
    required String   amount,
    required Color    color,
  }) =>
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
                Text(detail,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — STUDENT MESS BILLS
// ─────────────────────────────────────────────────────────────────────────────
class _StudentBillsTab extends StatelessWidget {
  const _StudentBillsTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      // reads per-student bill records
      stream: FirebaseFirestore.instance
          .collection('student_mess_bills')
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  color: _kBlue));
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width : 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color       : _kBlueTint,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                      Icons.receipt_long_rounded,
                      color: _kBlue,
                      size : 30),
                ),
                const SizedBox(height: 14),
                const Text('No student bills found',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 15,
                        color     : _kText)),
                const SizedBox(height: 4),
                const Text(
                    'Student bill records will appear here',
                    style: TextStyle(
                        fontSize: 13, color: _kSubtext)),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          itemCount   : docs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final d = docs[index].data()
                as Map<String, dynamic>;

            final name        = d['name']        as String? ?? '—';
            final roll        = d['roll']        as String? ?? '—';
            final presentDays =
                (d['presentDays'] as num?)?.toInt() ?? 0;
            final bill =
                (d['bill'] as num?)?.toDouble() ?? 0.0;
            final mealType =
                d['mealType'] as String? ?? 'veg';
            final isVeg = mealType == 'veg';

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _kBorder, width: 1.2),
                boxShadow: const [
                  BoxShadow(
                      color     : Color(0x0C1565C0),
                      blurRadius: 10,
                      offset    : Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width : 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isVeg
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: Icon(
                      isVeg
                          ? Icons.eco_rounded
                          : Icons.set_meal_rounded,
                      color: isVeg
                          ? Colors.green.shade600
                          : Colors.orange.shade600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize  : 14,
                                color     : _kText)),
                        const SizedBox(height: 3),
                        Text(
                          'Roll: $roll  •  Present: $presentDays days',
                          style: const TextStyle(
                              fontSize: 11,
                              color   : _kSubtext),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical  : 2),
                          decoration: BoxDecoration(
                            color: isVeg
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Text(
                            isVeg ? 'Veg' : 'Non-Veg',
                            style: TextStyle(
                              fontSize  : 10,
                              fontWeight: FontWeight.w700,
                              color     : isVeg
                                  ? Colors.green.shade600
                                  : Colors.orange.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bill amount
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${bill.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize  : 18,
                            color     : _kBlue),
                      ),
                      const Text('total bill',
                          style: TextStyle(
                              fontSize: 10,
                              color   : _kSubtext)),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS
// ─────────────────────────────────────────────────────────────────────────────
Widget _card({required Widget child, EdgeInsets? margin}) =>
    Container(
      width  : double.infinity,
      margin : margin,
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

Widget _infoRow(
  String label,
  String value, {
  bool   isBold     = false,
  Color? valueColor,
}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize  : 13,
                  color     : _kSubtext,
                  fontWeight: isBold
                      ? FontWeight.w700
                      : FontWeight.w500)),
          Text(value,
              style: TextStyle(
                  fontSize  : 14,
                  fontWeight: isBold
                      ? FontWeight.w800
                      : FontWeight.w600,
                  color: valueColor ?? _kText)),
        ],
      ),
    );