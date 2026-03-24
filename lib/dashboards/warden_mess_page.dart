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

class WardenMessPage extends StatefulWidget {
  const WardenMessPage({super.key});

  @override
  State<WardenMessPage> createState() => _WardenMessPageState();
}

class _WardenMessPageState extends State<WardenMessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 5 tabs: Attendance, Mess Bill, Calculation,
    //         Ordered List, Verified List
    _tabController = TabController(length: 5, vsync: this);
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
                  // Back + title
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
                                'Attendance, bills & orders',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab bar inside header — scrollable for 5 tabs
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller       : _tabController,
                        isScrollable     : true,
                        tabAlignment     : TabAlignment.start,
                        indicator        : BoxDecoration(
                          color        : Colors.white,
                          borderRadius : BorderRadius.circular(10),
                        ),
                        indicatorSize    :
                            TabBarIndicatorSize.tab,
                        labelColor       : _kBlue,
                        unselectedLabelColor: Colors.white,
                        labelStyle       : const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 13),
                        unselectedLabelStyle:
                            const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize  : 13),
                        padding:
                            const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: 'Attendance'),
                          Tab(text: 'Mess Bill'),
                          Tab(text: 'Calculation'),
                          Tab(text: 'Ordered List'),
                          Tab(text: 'Verified List'),
                        ],
                      ),
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
                _AttendanceTab(),
                _MessBillTab(),
                _CalculationTab(),
                _OrderedListTab(),
                _VerifiedListTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — HOSTEL ATTENDANCE
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .orderBy('date', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child:
                  CircularProgressIndicator(color: _kBlue));
        }

        if (snapshot.data!.docs.isEmpty) {
          return _emptyState(Icons.how_to_reg_rounded,
              'No attendance records found');
        }

        final data = snapshot.data!.docs.first.data()
            as Map<String, dynamic>;
        final records =
            List<Map<String, dynamic>>.from(
                data['records'] ?? []);

        final presentCount =
            records.where((r) => r['present'] == true).length;
        final total   = records.length;
        final percent =
            total == 0 ? 0.0 : presentCount / total;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Summary card
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
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _statBubble('$presentCount',
                            'Present',
                            Colors.green.shade600),
                        _statBubble(
                            '${total - presentCount}',
                            'Absent',
                            Colors.red.shade400),
                        _statBubble(
                            '$total', 'Total', _kBlue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value          : percent,
                        minHeight      : 10,
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
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.people_rounded, 'Student List'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: List.generate(
                    records.length,
                    (index) {
                      final r         = records[index];
                      final isPresent = r['present'] == true;
                      final isLast =
                          index == records.length - 1;
                      final room =
                          r['room']?.toString() ?? '—';

                      return Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                    vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  width : 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? Colors
                                            .green.shade50
                                        : Colors
                                            .red.shade50,
                                    borderRadius:
                                        BorderRadius
                                            .circular(10),
                                  ),
                                  child: Icon(
                                    isPresent
                                        ? Icons.check_rounded
                                        : Icons.close_rounded,
                                    color: isPresent
                                        ? Colors
                                            .green.shade600
                                        : Colors
                                            .red.shade400,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        r['name']
                                                ?.toString() ??
                                            '—',
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight.w600,
                                            fontSize: 13,
                                            color   : _kText),
                                      ),
                                      Text('Room: $room',
                                          style:
                                              const TextStyle(
                                                  fontSize: 11,
                                                  color:
                                                      _kSubtext)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical  : 4),
                                  decoration: BoxDecoration(
                                    color: isPresent
                                        ? Colors
                                            .green.shade50
                                        : Colors
                                            .red.shade50,
                                    borderRadius:
                                        BorderRadius
                                            .circular(20),
                                  ),
                                  child: Text(
                                    isPresent
                                        ? 'Present'
                                        : 'Absent',
                                    style: TextStyle(
                                      fontSize  : 11,
                                      fontWeight:
                                          FontWeight.w700,
                                      color: isPresent
                                          ? Colors
                                              .green.shade600
                                          : Colors
                                              .red.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — MESS BILL SUMMARY
// ─────────────────────────────────────────────────────────────────────────────
class _MessBillTab extends StatelessWidget {
  const _MessBillTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mess_bill')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        int    vegCount    = 0;
        int    nonVegCount = 0;
        double vegRate     = 90;
        double nonVegRate  = 110;
        double totalBill   = 0;

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
          totalBill   =
              (d['totalBill']   as num?)?.toDouble() ??
                  (vegCount * vegRate +
                      nonVegCount * nonVegRate);
        }

        final double calculatedBill =
            (vegCount * vegRate) +
                (nonVegCount * nonVegRate);
        final int presentCount = vegCount + nonVegCount;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color     : Color(0x301565C0),
                        blurRadius: 14,
                        offset    : Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text('Total Estimated Bill',
                        style: TextStyle(
                            color  : Colors.white70,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(
                      '₹${(totalBill > 0 ? totalBill : calculatedBill).toStringAsFixed(2)}',
                      style: const TextStyle(
                          color     : Colors.white,
                          fontSize  : 32,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.summarize_rounded, 'Summary'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: [
                    _infoRow('Daily Veg Rate / student',
                        '₹${vegRate.toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Daily Non-Veg Rate / student',
                        '₹${nonVegRate.toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Present Students',
                        '$presentCount'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow(
                      'Calculated Bill',
                      '₹${calculatedBill.toStringAsFixed(2)}',
                      isBold    : true,
                      valueColor: _kBlue,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 3 — MESS BILL CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
class _CalculationTab extends StatelessWidget {
  const _CalculationTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mess_bill')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
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

        final double vegTotal =
            vegCount * vegRate;
        final double nonVegTotal =
            nonVegCount * nonVegRate;
        final double grandTotal =
            vegTotal + nonVegTotal;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding:
              const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _sectionHeader(
                  Icons.calculate_rounded,
                  'Bill Calculation'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: [
                    // Formula banner
                    Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _kBlueTint,
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                            color: _kBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                              Icons.functions_rounded,
                              color: _kBlue,
                              size : 18),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Formula: Count × Daily Rate per student',
                              style: TextStyle(
                                  fontSize  : 12,
                                  color     : _kBlue,
                                  fontWeight:
                                      FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Veg row
                    _calcRow(
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
                          height: 1, color: _kBorder),
                    ),

                    // Non-veg row
                    _calcRow(
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
                          height: 1, color: _kBorder),
                    ),

                    // Total
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Calculated',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize  : 15,
                                color     : _kText)),
                        Text(
                          '₹${grandTotal.toStringAsFixed(2)}',
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
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — ORDERED LIST
// ─────────────────────────────────────────────────────────────────────────────
class _OrderedListTab extends StatelessWidget {
  const _OrderedListTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          padding:
              const EdgeInsets.fromLTRB(20, 24, 20, 36),
          itemCount       : docs.length,
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
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color       : _kBlueTint,
                          borderRadius:
                              BorderRadius.circular(10),
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
                        item['item']?.toString() ?? '',
                        item['qty']?.toString()  ?? '',
                        item['brand']?.toString() ?? '',
                      )),
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
// TAB 5 — VERIFIED LIST
// ─────────────────────────────────────────────────────────────────────────────
class _VerifiedListTab extends StatelessWidget {
  const _VerifiedListTab();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
          padding:
              const EdgeInsets.fromLTRB(20, 24, 20, 36),
          itemCount       : docs.length,
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
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isVerified
                              ? Icons.verified_rounded
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
                                      ? Colors
                                          .green.shade600
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
                        item['item']?.toString()  ?? '',
                        item['qty']?.toString()   ?? '',
                        item['brand']?.toString() ?? '',
                      )),
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
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize  : 13,
                      color     : _kText)),
              Text(detail,
                  style: const TextStyle(
                      fontSize: 11,
                      color   : _kSubtext)),
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
              color: color.withOpacity(0.25),
              width: 1.2),
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

Widget _itemRow(
        String item, String qty, String brand) =>
    Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 12,
                      color   : _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 60,
              child: Text(qty,
                  style: const TextStyle(
                      fontSize: 12,
                      color   : _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 80,
              child: Text(brand,
                  style: const TextStyle(
                      fontSize: 12,
                      color   : _kText))),
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

Widget _emptyState(
        IconData icon, String message) =>
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
                  borderRadius:
                      BorderRadius.circular(18)),
              child:
                  Icon(icon, color: _kBlue, size: 30),
            ),
            const SizedBox(height: 14),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color   : _kSubtext)),
          ],
        ),
      ),
    );

String _fmtDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/'
    '${dt.month.toString().padLeft(2, '0')}/'
    '${dt.year}';