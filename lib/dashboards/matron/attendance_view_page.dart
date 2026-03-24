import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class AttendanceViewPage extends StatefulWidget {
  const AttendanceViewPage({super.key});

  @override
  State<AttendanceViewPage> createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceViewPage> {
  // Start from current month, allow going back but not into future
  late DateTime _selectedMonth;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(_today.year, _today.month);
  }

  String get _monthKey => DateFormat('yyyy-MM').format(_selectedMonth);
  String get _monthLabel => DateFormat('MMMM yyyy').format(_selectedMonth);

  bool get _isCurrentMonth =>
      _selectedMonth.year == _today.year &&
      _selectedMonth.month == _today.month;

  void _prevMonth() {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (_isCurrentMonth) return;
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  // Month picker dialog
  Future<void> _pickMonth() async {
    DateTime temp = _selectedMonth;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          backgroundColor : Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Text('Select Month',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize  : 17,
                  color     : _kText)),
          content: SizedBox(
            width: 280,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Year row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () =>
                          setInner(() => temp = DateTime(temp.year - 1, temp.month)),
                      icon: const Icon(Icons.chevron_left_rounded,
                          color: _kBlue),
                    ),
                    Text(temp.year.toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 16,
                            color     : _kText)),
                    IconButton(
                      onPressed: temp.year >= _today.year
                          ? null
                          : () => setInner(
                              () => temp = DateTime(temp.year + 1, temp.month)),
                      icon: Icon(Icons.chevron_right_rounded,
                          color: temp.year >= _today.year
                              ? _kBorder
                              : _kBlue),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Month grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing  : 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (_, i) {
                    final month     = i + 1;
                    final isFuture  = DateTime(temp.year, month)
                        .isAfter(DateTime(_today.year, _today.month));
                    final isSelected = temp.month == month;

                    return GestureDetector(
                      onTap: isFuture
                          ? null
                          : () => setInner(() => temp = DateTime(temp.year, month)),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _kBlue
                              : isFuture
                                  ? const Color(0xFFF0F0F0)
                                  : _kBlueTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          DateFormat('MMM')
                              .format(DateTime(2000, month)),
                          style: TextStyle(
                              fontSize  : 12,
                              fontWeight: FontWeight.w600,
                              color     : isSelected
                                  ? Colors.white
                                  : isFuture
                                      ? _kSubtext
                                      : _kBlue),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                side : const BorderSide(color: _kBorder),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: const Text('Cancel',
                  style: TextStyle(color: _kSubtext)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _selectedMonth = temp);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
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
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back row
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
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Attendance',
                                style: TextStyle(
                                    color     : Colors.white,
                                    fontSize  : 20,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3)),
                            SizedBox(height: 2),
                            Text('Monthly student attendance records',
                                style: TextStyle(
                                    color  : Colors.white70,
                                    fontSize: 12)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Month navigator ──────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          // Prev
                          GestureDetector(
                            onTap: _prevMonth,
                            child: Container(
                              width : 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                  Icons.chevron_left_rounded,
                                  color: Colors.white,
                                  size : 20),
                            ),
                          ),

                          // Month label — tap to open picker
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickMonth,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                      Icons.calendar_month_rounded,
                                      color: Colors.white70,
                                      size : 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    _monthLabel,
                                    style: const TextStyle(
                                        color     : Colors.white,
                                        fontSize  : 15,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.white70,
                                      size : 16),
                                ],
                              ),
                            ),
                          ),

                          // Next (disabled on current month)
                          GestureDetector(
                            onTap: _isCurrentMonth ? null : _nextMonth,
                            child: Container(
                              width : 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white
                                    .withOpacity(
                                        _isCurrentMonth ? 0.07 : 0.18),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                  Icons.chevron_right_rounded,
                                  color: Colors.white.withOpacity(
                                      _isCurrentMonth ? 0.35 : 1.0),
                                  size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Records ───────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .doc(_monthKey)
                  .collection('records')
                  .orderBy('room')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: _kBlue));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                              Icons.event_busy_rounded,
                              color: _kBlue,
                              size : 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No records found',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('No attendance data for $_monthLabel',
                            style: const TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final r =
                        docs[i].data() as Map<String, dynamic>;
                    final present = r['present'] ?? 0;
                    final total   = r['total']   ?? 0;
                    final pct     = total > 0
                        ? (present / total).clamp(0.0, 1.0)
                        : 0.0;

                    return _AttendanceCard(
                      name   : r['name']    ?? '',
                      room   : r['room'].toString(),
                      present: present,
                      total  : total,
                      pct    : pct,
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

// ── Attendance card ───────────────────────────────────────────────────────────
class _AttendanceCard extends StatelessWidget {
  final String name;
  final String room;
  final int    present;
  final int    total;
  final double pct;

  const _AttendanceCard({
    required this.name,
    required this.room,
    required this.present,
    required this.total,
    required this.pct,
  });

  Color get _countColor {
    if (pct >= 0.75) return const Color(0xFF2E7D32);
    if (pct >= 0.5)  return const Color(0xFFF57C00);
    return Colors.red.shade600;
  }

  Color get _countBg {
    if (pct >= 0.75) return const Color(0xFFE8F5E9);
    if (pct >= 0.5)  return const Color(0xFFFFF8E1);
    return Colors.red.shade50;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border      : Border.all(color: _kBorder, width: 1.2),
          boxShadow   : const [
            BoxShadow(
                color     : Color(0x0F1565C0),
                blurRadius: 10,
                offset    : Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            // Room badge
            Container(
              width : 48,
              height: 48,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Room',
                      style: TextStyle(
                          fontSize: 9,
                          color   : _kSubtext,
                          fontWeight: FontWeight.w500)),
                  Text(room,
                      style: const TextStyle(
                          fontSize  : 14,
                          fontWeight: FontWeight.w800,
                          color     : _kBlue)),
                ],
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 14,
                          color     : _kText)),

                  const SizedBox(height: 8),

                  // Present / Total count
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color       : _countBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$present',
                                style: TextStyle(
                                    fontSize  : 15,
                                    fontWeight: FontWeight.w800,
                                    color     : _countColor),
                              ),
                              TextSpan(
                                text: ' / $total',
                                style: const TextStyle(
                                    fontSize  : 14,
                                    fontWeight: FontWeight.w600,
                                    color     : _kSubtext),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('days present',
                          style: TextStyle(
                              fontSize: 12, color: _kSubtext)),
                    ],
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