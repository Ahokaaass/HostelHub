import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../student_data.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class StudentMessPage extends StatefulWidget {
  const StudentMessPage({super.key});

  @override
  State<StudentMessPage> createState() =>
      _StudentMessPageState();
}

class _StudentMessPageState extends State<StudentMessPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
                crossAxisAlignment:
                    CrossAxisAlignment.start,
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
                                'Bill, menu, duties & more',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 16, 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            Colors.white.withOpacity(0.15),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller         : _tabController,
                        isScrollable       : true,
                        tabAlignment       :
                            TabAlignment.start,
                        indicator          : BoxDecoration(
                          color       : Colors.white,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        indicatorSize      :
                            TabBarIndicatorSize.tab,
                        labelColor         : _kBlue,
                        unselectedLabelColor:
                            Colors.white,
                        labelStyle         : const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 13),
                        unselectedLabelStyle:
                            const TextStyle(
                                fontWeight:
                                    FontWeight.w500,
                                fontSize: 13),
                        padding:
                            const EdgeInsets.all(4),
                        tabs: const [
                          Tab(text: 'My Bill'),
                          Tab(text: 'Calculation'),
                          Tab(text: 'Menu'),
                          Tab(text: 'My Duties'),
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
              children: [
                _MyBillTab(
                    admissionNo: StudentData.admissionNo),
                const _CalculationTab(),
                const _MenuTab(),
                _DutiesTab(
                    admissionNo: StudentData.admissionNo),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 1 — MY MESS BILL
// ─────────────────────────────────────────────────────────────────────────────
class _MyBillTab extends StatelessWidget {
  final String admissionNo;
  const _MyBillTab({required this.admissionNo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('student_mess_bills')
          .where('admissionNo', isEqualTo: admissionNo)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
              child: CircularProgressIndicator(
                  color: _kBlue));
        }

        // ── derive values ─────────────────────────────────
        double bill         = 0;
        int    presentDays  = 0;
        double dailyRate    = 0;
        String mealType     = 'veg';
        String month        = '';

        if (snapshot.data!.docs.isNotEmpty) {
          final d = snapshot.data!.docs.first.data()
              as Map<String, dynamic>;
          bill        =
              (d['bill']        as num?)?.toDouble() ?? 0;
          presentDays =
              (d['presentDays'] as num?)?.toInt()    ?? 0;
          dailyRate   =
              (d['dailyRate']   as num?)?.toDouble() ?? 0;
          mealType    =
              d['mealType']   as String? ?? 'veg';
          month       =
              d['month']      as String? ?? '';
        }

        final isVeg     = mealType == 'veg';
        final calculated =
            presentDays * dailyRate;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              20, 24, 20, 36),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // ── Bill banner ───────────────────────────────
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
                        offset    : Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('My Mess Bill',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 13)),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical  : 4),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),
                          child: Text(
                            isVeg ? '🥗 Veg' : '🍗 Non-Veg',
                            style: const TextStyle(
                                color     : Colors.white,
                                fontSize  : 11,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '₹${bill > 0 ? bill.toStringAsFixed(2) : calculated.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color     : Colors.white,
                          fontSize  : 36,
                          fontWeight: FontWeight.w800),
                    ),
                    if (month.isNotEmpty)
                      Text(month,
                          style: const TextStyle(
                              color  : Colors.white70,
                              fontSize: 12)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.info_outline_rounded,
                  'Bill Details'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: [
                    _infoRow('Meal Type',
                        isVeg ? 'Vegetarian' : 'Non-Vegetarian'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Days Present',
                        '$presentDays days'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Daily Rate',
                        '₹${dailyRate.toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow(
                      'Total Bill',
                      '₹${(bill > 0 ? bill : calculated).toStringAsFixed(2)}',
                      isBold    : true,
                      valueColor: _kBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.history_rounded,
                  'Bill History'),
              const SizedBox(height: 12),

              // Bill history stream
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('student_mess_bills')
                    .where('admissionNo',
                        isEqualTo: admissionNo)
                    .orderBy('createdAt',
                        descending: true)
                    .snapshots(),
                builder: (context, histSnap) {
                  if (!histSnap.hasData) {
                    return const SizedBox();
                  }

                  final docs = histSnap.data!.docs;

                  if (docs.isEmpty) {
                    return _emptyState(
                        Icons.history_rounded,
                        'No bill history yet');
                  }

                  return _card(
                    child: Column(
                      children:
                          List.generate(docs.length, (i) {
                        final d = docs[i].data()
                            as Map<String, dynamic>;
                        final m =
                            d['month'] as String? ?? '—';
                        final b =
                            (d['bill'] as num?)
                                    ?.toDouble() ??
                                0.0;
                        final isLast =
                            i == docs.length - 1;

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets
                                  .symmetric(vertical: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width : 36,
                                    height: 36,
                                    decoration:
                                        BoxDecoration(
                                      color: _kBlueTint,
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                                  10),
                                    ),
                                    child: const Icon(
                                        Icons
                                            .receipt_long_rounded,
                                        color: _kBlue,
                                        size : 16),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                      child: Text(m,
                                          style: const TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .w600,
                                              fontSize: 13,
                                              color   : _kText))),
                                  Text(
                                    '₹${b.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                        fontSize: 14,
                                        color   : _kBlue),
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
                      }),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 2 — BILL CALCULATION
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
        double vegRate    = 90;
        double nonVegRate = 110;

        if (snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          final d = snapshot.data!.docs.first.data()
              as Map<String, dynamic>;
          vegRate    =
              (d['vegRate']    as num?)?.toDouble() ?? 90;
          nonVegRate =
              (d['nonVegRate'] as num?)?.toDouble() ?? 110;
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              20, 24, 20, 36),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              _sectionHeader(
                  Icons.calculate_rounded,
                  'How Your Bill is Calculated'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  children: [
                    // Formula box
                    Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color       : _kBlueTint,
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
                              size : 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: const [
                                Text('Formula',
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                        fontSize: 12,
                                        color   : _kBlue)),
                                SizedBox(height: 2),
                                Text(
                                    'Days Present × Daily Rate',
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.w600,
                                        fontSize: 14,
                                        color   : _kText)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _calcRow(
                      icon  : Icons.eco_rounded,
                      label : 'Veg Daily Rate',
                      detail:
                          'Per student, per day',
                      amount: '₹${vegRate.toStringAsFixed(0)}',
                      color : Colors.green.shade600,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 10),
                      child: Divider(
                          height: 1, color: _kBorder),
                    ),
                    _calcRow(
                      icon  : Icons.set_meal_rounded,
                      label : 'Non-Veg Daily Rate',
                      detail: 'Per student, per day',
                      amount:
                          '₹${nonVegRate.toStringAsFixed(0)}',
                      color : Colors.orange.shade600,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              _sectionHeader(
                  Icons.lightbulb_outline_rounded,
                  'Example'),
              const SizedBox(height: 12),

              _card(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    _infoRow('Veg student, 25 days',
                        '25 × ₹${vegRate.toStringAsFixed(0)} = ₹${(25 * vegRate).toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    _infoRow('Non-veg student, 25 days',
                        '25 × ₹${nonVegRate.toStringAsFixed(0)} = ₹${(25 * nonVegRate).toStringAsFixed(0)}'),
                    const Divider(
                        height: 1, color: _kBorder),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 8),
                      child: Text(
                        'Bills are calculated monthly based on actual attendance',
                        style: TextStyle(
                            fontSize: 12,
                            color   : _kSubtext),
                      ),
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
// TAB 3 — WEEKLY MENU
// ─────────────────────────────────────────────────────────────────────────────
class _MenuTab extends StatelessWidget {
  const _MenuTab();

  // Static weekly menu — matches others_tab_screen data
  static const List<Map<String, String>> _menu = [
    {
      'day'      : 'Monday',
      'breakfast': 'Idli + Sambar',
      'lunch'    : 'Rice + Dal',
      'snack'    : 'Pazham',
      'dinner'   : 'Chapati + Curry',
    },
    {
      'day'      : 'Tuesday',
      'breakfast': 'Dosa',
      'lunch'    : 'Rice + Sambar',
      'snack'    : 'Tea + Biscuit',
      'dinner'   : 'Puttu + Kadala',
    },
    {
      'day'      : 'Wednesday',
      'breakfast': 'Idiyappam',
      'lunch'    : 'Rice + Rasam',
      'snack'    : 'Pazham',
      'dinner'   : 'Chapati',
    },
    {
      'day'      : 'Thursday',
      'breakfast': 'Upma',
      'lunch'    : 'Rice + Dal',
      'snack'    : 'Tea',
      'dinner'   : 'Fried Rice',
    },
    {
      'day'      : 'Friday',
      'breakfast': 'Poori',
      'lunch'    : 'Veg Biriyani',
      'snack'    : 'Biscuit',
      'dinner'   : 'Chapati',
    },
    {
      'day'      : 'Saturday',
      'breakfast': 'Dosa',
      'lunch'    : 'Rice + Curry',
      'snack'    : 'Tea',
      'dinner'   : 'Noodles',
    },
    {
      'day'      : 'Sunday',
      'breakfast': 'Idli',
      'lunch'    : 'Special Meals',
      'snack'    : 'Juice',
      'dinner'   : 'Chapati',
    },
  ];

  // Highlight today's menu
  static const List<String> _days = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday'
  ];

  @override
  Widget build(BuildContext context) {
    // 1 = Monday … 7 = Sunday
    final todayIndex =
        DateTime.now().weekday - 1;

    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
          20, 24, 20, 36),
      itemCount       : _menu.length,
      separatorBuilder: (_, __) =>
          const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final day      = _menu[index];
        final isToday  = index == todayIndex;

        return Container(
          decoration: BoxDecoration(
            color: isToday ? _kBlueTint : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday ? _kBlue : _kBorder,
              width: isToday ? 1.8 : 1.2,
            ),
            boxShadow: const [
              BoxShadow(
                  color     : Color(0x0C1565C0),
                  blurRadius: 10,
                  offset    : Offset(0, 3)),
            ],
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: isToday,
              tilePadding:
                  const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
              title: Row(
                children: [
                  Container(
                    width : 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isToday
                          ? _kBlue
                          : _kBlueTint,
                      borderRadius:
                          BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        day['day']!
                            .substring(0, 2)
                            .toUpperCase(),
                        style: TextStyle(
                            fontSize  : 11,
                            fontWeight: FontWeight.w800,
                            color     : isToday
                                ? Colors.white
                                : _kBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(day['day']!,
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 14,
                              color     : isToday
                                  ? _kBlue
                                  : _kText)),
                      if (isToday)
                        const Text('Today',
                            style: TextStyle(
                                fontSize  : 11,
                                color     : _kBlue,
                                fontWeight:
                                    FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      16, 0, 16, 16),
                  child: Column(
                    children: [
                      _menuMealRow(
                          Icons.wb_sunny_rounded,
                          'Breakfast',
                          day['breakfast']!,
                          Colors.orange.shade400),
                      const SizedBox(height: 8),
                      _menuMealRow(
                          Icons.wb_cloudy_rounded,
                          'Lunch',
                          day['lunch']!,
                          Colors.blue.shade400),
                      const SizedBox(height: 8),
                      _menuMealRow(
                          Icons.coffee_rounded,
                          'Snack',
                          day['snack']!,
                          Colors.brown.shade300),
                      const SizedBox(height: 8),
                      _menuMealRow(
                          Icons.nights_stay_rounded,
                          'Dinner',
                          day['dinner']!,
                          Colors.indigo.shade400),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _menuMealRow(IconData icon, String meal,
      String items, Color color) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width : 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 72,
            child: Text(meal,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize  : 12,
                    color     : _kSubtext)),
          ),
          Expanded(
            child: Text(items,
                style: const TextStyle(
                    fontSize: 12, color: _kText)),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TAB 4 — MY MESS DUTIES
// ─────────────────────────────────────────────────────────────────────────────
class _DutiesTab extends StatelessWidget {
  final String admissionNo;
  const _DutiesTab({required this.admissionNo});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mess_duties')
          .where('admissionNo', isEqualTo: admissionNo)
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
              Icons.assignment_turned_in_rounded,
              'No duties assigned yet');
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
              20, 24, 20, 36),
          itemCount       : docs.length,
          separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final d = docs[index].data()
                as Map<String, dynamic>;

            final duty    =
                d['duty']    as String? ?? '—';
            final date    =
                d['date']    as String? ?? '—';
            final session =
                d['session'] as String? ?? '—';
            final done    =
                d['done']    as bool? ?? false;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(16),
                border: Border.all(
                  color: done
                      ? Colors.green.shade200
                      : _kBorder,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                      color     : Color(0x0C1565C0),
                      blurRadius: 10,
                      offset    : Offset(0, 3)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: done
                          ? Colors.green.shade50
                          : _kBlueTint,
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: Icon(
                      done
                          ? Icons
                              .check_circle_rounded
                          : Icons
                              .assignment_turned_in_rounded,
                      color: done
                          ? Colors.green.shade600
                          : _kBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(duty,
                            style: const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                                fontSize: 13,
                                color   : _kText)),
                        const SizedBox(height: 3),
                        Text(
                          '$date  •  $session',
                          style: const TextStyle(
                              fontSize: 11,
                              color   : _kSubtext),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical  : 4),
                    decoration: BoxDecoration(
                      color: done
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius:
                          BorderRadius.circular(20),
                    ),
                    child: Text(
                      done ? 'Done' : 'Pending',
                      style: TextStyle(
                          fontSize  : 11,
                          fontWeight: FontWeight.w700,
                          color     : done
                              ? Colors.green.shade600
                              : Colors.orange
                                  .shade700),
                    ),
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
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    fontSize  : 13,
                    color     : _kSubtext,
                    fontWeight: isBold
                        ? FontWeight.w700
                        : FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize  : 13,
                    fontWeight: isBold
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: valueColor ?? _kText)),
          ),
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
              child:
                  Icon(icon, color: _kBlue, size: 30),
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