import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/dashboard_scaffold.dart';
import '../../core/service_tile.dart';
import '../../core/emergency_service_tile.dart';
import '../../staff/profile/staff_profile_page.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class PrincipalDashboard extends StatefulWidget {
  const PrincipalDashboard({super.key});

  @override
  State<PrincipalDashboard> createState() =>
      _PrincipalDashboardState();
}

class _PrincipalDashboardState extends State<PrincipalDashboard> {
  static const _userId = 'principal';

  String _userName = '';
  bool   _loading  = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(_userId)
          .get();
      setState(
          () => _userName = doc.data()?['name'] ?? 'Principal');
    } catch (_) {
      setState(() => _userName = 'Principal');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'Principal Dashboard',
      userName     : _loading ? '...' : _userName,
      onProfileTap : () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) =>
                const StaffProfilePage(userId: _userId)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Services label ──────────────────────────────────────
          Row(children: [
            Container(
              width : 36,
              height: 36,
              decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grid_view_rounded,
                  color: _kBlue, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Services',
                style: TextStyle(
                    fontSize     : 16,
                    fontWeight   : FontWeight.w800,
                    color        : _kText,
                    letterSpacing: -0.2)),
          ]),

          const SizedBox(height: 16),

          // ── Services grid ───────────────────────────────────────
          GridView.count(
            crossAxisCount  : 2,
            shrinkWrap      : true,
            physics         : const NeverScrollableScrollPhysics(),
            mainAxisSpacing : 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.05,
            children: [

              ServiceTile(
                icon : Icons.how_to_reg_rounded,
                title: 'Attendance',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const _AttendancePage())),
              ),

              ServiceTile(
                icon : Icons.receipt_long_rounded,
                title: 'Mess Bill',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const _MessBillPage())),
              ),

              ServiceTile(
                icon : Icons.shopping_cart_rounded,
                title: 'Ordered List',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const _OrderedListPage())),
              ),

              ServiceTile(
                icon : Icons.verified_rounded,
                title: 'Verified List',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const _VerifiedListPage())),
              ),

              EmergencyServiceTile(
                userId: _userId,
                onTap : () {
                  // navigate to emergency page if you have one
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED: header + card helpers used across all sub-pages
// ─────────────────────────────────────────────────────────────────────────────

Widget _pageHeader(BuildContext context, String title,
    String subtitle, IconData icon) {
  return Container(
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
                      color:
                          Colors.white.withOpacity(0.3)),
                ),
                child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size : 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color        : Colors.white,
                          fontSize     : 20,
                          fontWeight   : FontWeight.w800,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(
                          color  : Colors.white70,
                          fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

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

Widget _infoRow(String label, String value,
    {bool isBold = false, Color? valueColor}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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

Widget _emptyState(IconData icon, String message) =>
    Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width : 64,
              height: 64,
              decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(18)),
              child: Icon(icon, color: _kBlue, size: 30),
            ),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: _kSubtext)),
          ],
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// 1. ATTENDANCE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _AttendancePage extends StatelessWidget {
  const _AttendancePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _pageHeader(context, 'Attendance',
              'Student presence overview',
              Icons.how_to_reg_rounded),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .orderBy('date', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _kBlue));
                }

                if (snapshot.data!.docs.isEmpty) {
                  return _emptyState(
                      Icons.how_to_reg_rounded,
                      'No attendance records found');
                }

                final doc  = snapshot.data!.docs.first;
                final data = doc.data() as Map<String, dynamic>;
                final records = List<Map<String, dynamic>>.from(
                    data['records'] ?? []);

                final presentCount = records
                    .where((r) => r['present'] == true)
                    .length;
                final total   = records.length;
                final percent =
                    total == 0 ? 0.0 : presentCount / total;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 36),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // ── Summary card ────────────────────────────
                      _card(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                                Icons.bar_chart_rounded,
                                'Summary'),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                _statBubble(
                                    '$presentCount',
                                    'Present',
                                    Colors.green.shade600),
                                _statBubble(
                                    '${total - presentCount}',
                                    'Absent',
                                    Colors.red.shade400),
                                _statBubble(
                                    '$total',
                                    'Total',
                                    _kBlue),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value      : percent,
                                minHeight  : 10,
                                backgroundColor:
                                    Colors.grey.shade200,
                                color: percent >= 0.9
                                    ? Colors.green.shade500
                                    : Colors.orange.shade500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(percent * 100).toStringAsFixed(1)}% attendance',
                              style: const TextStyle(
                                  fontSize  : 12,
                                  color     : _kSubtext,
                                  fontWeight:
                                      FontWeight.w500),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      _sectionHeader(
                          Icons.people_rounded,
                          'Student List'),
                      const SizedBox(height: 12),

                      // ── Student rows ────────────────────────────
                      // Fix: use a local variable for length
                      // so it's accessible inside the builder
                      _card(
                        child: Column(
                          children: List.generate(
                            records.length,
                            (index) {
                              final r = records[index];
                              final isPresent =
                                  r['present'] == true;
                              final isLast =
                                  index == records.length - 1;

                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width : 36,
                                          height: 36,
                                          decoration:
                                              BoxDecoration(
                                            color: isPresent
                                                ? Colors.green
                                                    .shade50
                                                : Colors.red
                                                    .shade50,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        10),
                                          ),
                                          child: Icon(
                                            isPresent
                                                ? Icons
                                                    .check_rounded
                                                : Icons
                                                    .close_rounded,
                                            color: isPresent
                                                ? Colors.green
                                                    .shade600
                                                : Colors.red
                                                    .shade400,
                                            size: 18,
                                          ),
                                        ),
                                        const SizedBox(
                                            width: 12),
                                        Expanded(
                                          child: Text(
                                            r['name']
                                                    ?.toString() ??
                                                '—',
                                            style: const TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                                fontSize: 13,
                                                color   : _kText),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets
                                              .symmetric(
                                              horizontal: 10,
                                              vertical  : 4),
                                          decoration:
                                              BoxDecoration(
                                            color: isPresent
                                                ? Colors.green
                                                    .shade50
                                                : Colors.red
                                                    .shade50,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        20),
                                          ),
                                          child: Text(
                                            isPresent
                                                ? 'Present'
                                                : 'Absent',
                                            style: TextStyle(
                                              fontSize  : 11,
                                              fontWeight:
                                                  FontWeight
                                                      .w700,
                                              color: isPresent
                                                  ? Colors
                                                      .green
                                                      .shade600
                                                  : Colors
                                                      .red
                                                      .shade500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // ── Divider fix ─────────────
                                  // was: if (e.key < records.length - 1)
                                  // fix: use local isLast bool
                                  if (!isLast)
                                    const Divider(
                                        height: 1,
                                        color : _kBorder),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBubble(
          String value, String label, Color color) =>
      Column(children: [
        Container(
          width : 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: color.withOpacity(0.25), width: 1.2),
          ),
          child: Center(
            child: Text(value,
                style: TextStyle(
                    fontSize  : 20,
                    fontWeight: FontWeight.w800,
                    color     : color)),
          ),
        ),
        const SizedBox(height: 5),
        Text(label,
            style: const TextStyle(
                fontSize  : 11,
                color     : _kSubtext,
                fontWeight: FontWeight.w500)),
      ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. MESS BILL PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _MessBillPage extends StatelessWidget {
  const _MessBillPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _pageHeader(context, 'Mess Bill',
              'Bill summary & calculation',
              Icons.receipt_long_rounded),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('mess_bill')
                  .orderBy('createdAt', descending: true)
                  .limit(1)
                  .snapshots(),
              builder: (context, snap) {
                // ── Derive values ─────────────────────────────────
                int    vegCount    = 0;
                int    nonVegCount = 0;
                double vegRate     = 90;
                double nonVegRate  = 110;
                double totalBill   = 0;

                if (snap.hasData &&
                    snap.data!.docs.isNotEmpty) {
                  final d = snap.data!.docs.first.data()
                      as Map<String, dynamic>;
                  vegCount    =
                      (d['vegCount']    as num?)?.toInt() ?? 0;
                  nonVegCount =
                      (d['nonVegCount'] as num?)?.toInt() ?? 0;
                  vegRate     =
                      (d['vegRate']     as num?)?.toDouble() ??
                          90;
                  nonVegRate  =
                      (d['nonVegRate']  as num?)?.toDouble() ??
                          110;
                  totalBill   =
                      (d['totalBill']   as num?)?.toDouble() ??
                          (vegCount * vegRate +
                              nonVegCount * nonVegRate);
                }

                final double vegTotal    = vegCount * vegRate;
                final double nonVegTotal =
                    nonVegCount * nonVegRate;
                final double calculated  =
                    vegTotal + nonVegTotal;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 36),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      // Total banner
                      Container(
                        width  : double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin : Alignment.topLeft,
                            end   : Alignment.bottomRight,
                            colors: [_kBlue, _kBlueLight],
                          ),
                          borderRadius:
                              BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color     : Color(0x301565C0),
                              blurRadius: 14,
                              offset    : Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text('Total Mess Bill',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 13)),
                            const SizedBox(height: 6),
                            Text(
                              '₹${totalBill > 0 ? totalBill.toStringAsFixed(2) : calculated.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color     : Colors.white,
                                  fontSize  : 32,
                                  fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionHeader(
                          Icons.calculate_rounded,
                          'Bill Breakdown'),
                      const SizedBox(height: 12),

                      _card(
                        child: Column(
                          children: [
                            // Veg
                            _billCalcRow(
                              icon  : Icons.eco_rounded,
                              label : 'Veg Students',
                              detail:
                                  '$vegCount × ₹${vegRate.toStringAsFixed(0)}',
                              amount: '₹${vegTotal.toStringAsFixed(2)}',
                              color : Colors.green.shade600,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10),
                              child: Divider(
                                  height: 1,
                                  color : _kBorder),
                            ),
                            // Non-veg
                            _billCalcRow(
                              icon  : Icons.set_meal_rounded,
                              label : 'Non-Veg Students',
                              detail:
                                  '$nonVegCount × ₹${nonVegRate.toStringAsFixed(0)}',
                              amount:
                                  '₹${nonVegTotal.toStringAsFixed(2)}',
                              color : Colors.orange.shade600,
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10),
                              child: Divider(
                                  height: 1,
                                  color : _kBorder),
                            ),
                            // Total
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text('Total',
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.w800,
                                        fontSize: 15,
                                        color   : _kText)),
                                Text(
                                  '₹${calculated.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight:
                                          FontWeight.w800,
                                      fontSize: 16,
                                      color   : _kBlue),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                      _sectionHeader(
                          Icons.info_outline_rounded,
                          'Rate Details'),
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
                                'Count × Rate',
                                isBold: true,
                                valueColor: _kBlue),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _billCalcRow({
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
// 3. ORDERED LIST PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _OrderedListPage extends StatelessWidget {
  const _OrderedListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _pageHeader(context, 'Ordered List',
              'Items ordered for mess',
              Icons.shopping_cart_rounded),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchase_orders')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _kBlue));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _emptyState(
                      Icons.shopping_cart_rounded,
                      'No orders placed yet');
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 36),
                  itemCount   : docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = docs[index].data()
                        as Map<String, dynamic>;
                    final items =
                        List<Map<String, dynamic>>.from(
                            data['items'] ?? []);
                    final status =
                        data['status'] as String? ?? '';
                    final ts =
                        data['createdAt'] as Timestamp?;
                    final date = ts != null
                        ? _fmtDate(ts.toDate())
                        : '—';

                    return _card(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // Order header
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _kBlueTint,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                ),
                                child: const Icon(
                                    Icons.receipt_long_rounded,
                                    color: _kBlue,
                                    size : 16),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Order · $date',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w700,
                                            fontSize: 13,
                                            color   : _kText)),
                                    Text(
                                        '${items.length} items',
                                        style: const TextStyle(
                                            fontSize: 11,
                                            color   : _kSubtext)),
                                  ],
                                ),
                              ),
                              _statusChip(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                              height: 1, color: _kBorder),
                          const SizedBox(height: 8),
                          _colHeadings(),
                          const SizedBox(height: 4),
                          ...items.map((item) => _itemRow(
                                item['item']?.toString() ??
                                    '',
                                item['qty']?.toString() ??
                                    '',
                                item['brand']?.toString() ??
                                    '',
                              )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. VERIFIED LIST PAGE
// ─────────────────────────────────────────────────────────────────────────────
class _VerifiedListPage extends StatelessWidget {
  const _VerifiedListPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _pageHeader(context, 'Verified List',
              'Deliveries verified by Mess Secretary',
              Icons.verified_rounded),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('daily_deliveries')
                  .orderBy('submittedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _kBlue));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return _emptyState(
                      Icons.verified_rounded,
                      'No deliveries recorded yet');
                }

                return ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 36),
                  itemCount   : docs.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final data = docs[index].data()
                        as Map<String, dynamic>;
                    final items =
                        List<Map<String, dynamic>>.from(
                            data['receivedItems'] ?? []);
                    final status =
                        data['status'] as String? ?? '';
                    final isVerified = status == 'VERIFIED';

                    return _card(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isVerified
                                      ? Colors.green.shade50
                                      : _kBlueTint,
                                  borderRadius:
                                      BorderRadius.circular(
                                          10),
                                ),
                                child: Icon(
                                  isVerified
                                      ? Icons
                                          .verified_rounded
                                      : Icons
                                          .local_shipping_rounded,
                                  color: isVerified
                                      ? Colors.green.shade600
                                      : _kBlue,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Delivery · ${items.length} items',
                                      style: const TextStyle(
                                          fontWeight:
                                              FontWeight.w700,
                                          fontSize: 13,
                                          color   : _kText),
                                    ),
                                    Text(
                                      isVerified
                                          ? 'Verified by Mess Secretary'
                                          : 'Pending verification',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: isVerified
                                              ? Colors.green
                                                  .shade600
                                              : _kSubtext),
                                    ),
                                  ],
                                ),
                              ),
                              _statusChip(status),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(
                              height: 1, color: _kBorder),
                          const SizedBox(height: 8),
                          _colHeadings(),
                          const SizedBox(height: 4),
                          ...items.map((item) => _itemRow(
                                item['item']?.toString() ??
                                    '',
                                item['qty']?.toString() ??
                                    '',
                                item['brand']?.toString() ??
                                    '',
                              )),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED TABLE HELPERS
// ─────────────────────────────────────────────────────────────────────────────
Widget _colHeadings() => const Row(
      children: [
        Expanded(
            child: Text('Item',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
        SizedBox(width: 12),
        SizedBox(
            width: 60,
            child: Text('Qty',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
        SizedBox(width: 12),
        SizedBox(
            width: 80,
            child: Text('Brand',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
      ],
    );

Widget _itemRow(String item, String qty, String brand) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 60,
              child: Text(qty,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 80,
              child: Text(brand,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
        ],
      ),
    );

Widget _statusChip(String status) {
  Color  bg, fg;
  String label;
  switch (status) {
    case 'VERIFIED':
      bg    = Colors.green.shade50;
      fg    = Colors.green.shade700;
      label = 'Verified';
      break;
    case 'SENT_TO_PM':
      bg    = Colors.orange.shade50;
      fg    = Colors.orange.shade700;
      label = 'Sent to PM';
      break;
    default:
      bg    = _kBlueTint;
      fg    = _kBlue;
      label = status.isEmpty ? 'Pending' : status;
  }
  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color       : bg,
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize  : 10,
            fontWeight: FontWeight.w700,
            color     : fg)),
  );
}

String _fmtDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/'
    '${dt.month.toString().padLeft(2, '0')}/'
    '${dt.year}';