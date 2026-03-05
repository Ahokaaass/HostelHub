import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../student/student_data.dart';
import 'package:intl/intl.dart';

// ── THEME ─────────────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBg        = Color(0xFFF5F8FF);
const _kBorder    = Color(0xFFBBD0F8);
const _kBlueTint  = Color(0xFFE8F0FE);

// ── HELPERS ───────────────────────────────────────────────────────────────────
String _toMonthDocId(DateTime dt) =>
    '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

DateTime? _parseMonthDocId(String id) {
  try {
    final p = id.split('-');
    if (p.length == 2) return DateTime(int.parse(p[0]), int.parse(p[1]));
  } catch (_) {}
  return null;
}

String _prettyMonth(String id) {
  final dt = _parseMonthDocId(id);
  return dt == null ? id : DateFormat('MMMM yyyy').format(dt);
}

DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

// ─────────────────────────────────────────────────────────────────────────────
// DATABASE STRUCTURE (confirmed):
//   attendance/{yyyy-MM}/records/{admNo}
//     fields: present (int), total (int), name, room
//   attendance/{yyyy-MM}/records/{admNo}/days/{yyyy-MM-dd}
//     fields:
//       date:    "2026-01-23"   (String)
//       messCut: false          (bool)
//       status:  "present"      (String) ← KEY FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceData {
  final Map<String, Map<String, int>> monthly;
  final Map<DateTime, String> dayStatus; // DateTime → "present" | "absent"
  const _AttendanceData({required this.monthly, required this.dayStatus});
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class StudentAttendancePage extends StatefulWidget {
  const StudentAttendancePage({super.key});
  @override
  State<StudentAttendancePage> createState() => _StudentAttendancePageState();
}

class _StudentAttendancePageState extends State<StudentAttendancePage> {
  DateTime _viewMonth =
      DateTime(DateTime.now().year, DateTime.now().month);
  late final Future<_AttendanceData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadAll(StudentData.admissionNo);
  }

  Future<_AttendanceData> _loadAll(String admNo) async {
    final db        = FirebaseFirestore.instance;
    final monthly   = <String, Map<String, int>>{};
    final dayStatus = <DateTime, String>{};

    final monthsSnap = await db.collection('attendance').get();

    for (final mDoc in monthsSnap.docs) {
      final monthId   = mDoc.id;
      final recordRef = db
          .collection('attendance')
          .doc(monthId)
          .collection('records')
          .doc(admNo);

      final recSnap = await recordRef.get();
      if (!recSnap.exists) continue;

      final rd      = recSnap.data() as Map<String, dynamic>;
      final present = (rd['present'] ?? 0) as int;
      final total   = (rd['total']   ?? 0) as int;

      monthly[monthId] = {
        'present': present,
        'total'  : total,
        'absent' : total - present,
      };

      // ── Read days subcollection ──────────────────────────────────────
      // Each doc: { date: "2026-01-23", messCut: false, status: "present" }
      final daysSnap = await recordRef.collection('days').get();

      for (final dayDoc in daysSnap.docs) {
        final dd         = dayDoc.data();
        // Read the status field — "present" or "absent"
        final statusVal  = (dd['status'] ?? '').toString().toLowerCase().trim();
        final status     = statusVal == 'present' ? 'present' : 'absent';

        // Parse date from doc id "yyyy-MM-dd"
        try {
          final p  = dayDoc.id.split('-');
          final dt = _norm(DateTime(
              int.parse(p[0]), int.parse(p[1]), int.parse(p[2])));
          dayStatus[dt] = status;
        } catch (_) {}
      }
    }

    return _AttendanceData(monthly: monthly, dayStatus: dayStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: FutureBuilder<_AttendanceData>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }
                if (snap.hasError || snap.data == null) {
                  return _emptyState(
                      'Unable to load attendance.\nPlease try again.');
                }

                final data    = snap.data!;
                final nowKey  = _toMonthDocId(DateTime.now());
                final current = data.monthly[nowKey] ??
                    {'present': 0, 'total': 0, 'absent': 0};

                final sorted = data.monthly.entries.toList()
                  ..sort((a, b) {
                    final da = _parseMonthDocId(a.key);
                    final db = _parseMonthDocId(b.key);
                    if (da == null || db == null) return 0;
                    return db.compareTo(da);
                  });

                if (data.monthly.isEmpty) {
                  return _emptyState('No attendance found for your account');
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CurrentMonthCard(
                        present: current['present']!,
                        absent : current['absent']!,
                        total  : current['total']!,
                      ),
                      const SizedBox(height: 22),
                      _buildLegend(),
                      const SizedBox(height: 18),
                      _sectionLabel('Attendance Calendar'),
                      const SizedBox(height: 10),
                      _CustomCalendar(
                        viewMonth : _viewMonth,
                        dayStatus : data.dayStatus,
                        monthly   : data.monthly,
                        onPrev: () => setState(() => _viewMonth =
                            DateTime(_viewMonth.year, _viewMonth.month - 1)),
                        onNext: () => setState(() => _viewMonth =
                            DateTime(_viewMonth.year, _viewMonth.month + 1)),
                      ),
                      const SizedBox(height: 26),
                      _sectionLabel('Monthly Records'),
                      const SizedBox(height: 10),
                      ...sorted.map((e) => _MonthCard(
                            monthId: e.key,
                            present: e.value['present']!,
                            absent : e.value['absent']!,
                            total  : e.value['total']!,
                          )),
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

  Widget _buildHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kBlue, _kBlueLight],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft : Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Attendance',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMMM yyyy').format(DateTime.now()),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildLegend() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A1565C0),
                blurRadius: 6,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(Colors.green.shade500, 'Present'),
            const SizedBox(width: 20),
            _dot(Colors.red.shade400, 'Absent'),
            const SizedBox(width: 20),
            _dot(Colors.grey.shade300, 'No record'),
          ],
        ),
      );

  Widget _dot(Color c, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 10, height: 10,
              decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700)),
        ],
      );

  static Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF1A1A2E),
          letterSpacing: -0.2));

  static Widget _emptyState(String msg) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_busy_rounded,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 14),
            Text(msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM CALENDAR GRID
// ─────────────────────────────────────────────────────────────────────────────
class _CustomCalendar extends StatelessWidget {
  final DateTime viewMonth;
  final Map<DateTime, String> dayStatus;
  final Map<String, Map<String, int>> monthly;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _CustomCalendar({
    required this.viewMonth,
    required this.dayStatus,
    required this.monthly,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final today        = _norm(DateTime.now());
    final firstOfMonth = DateTime(viewMonth.year, viewMonth.month, 1);
    final startOffset  = (firstOfMonth.weekday - 1) % 7;
    final daysInMonth  =
        DateUtils.getDaysInMonth(viewMonth.year, viewMonth.month);

    final cells = <DateTime?>[
      ...List.filled(startOffset, null),
      ...List.generate(daysInMonth,
          (i) => DateTime(viewMonth.year, viewMonth.month, i + 1)),
    ];
    while (cells.length % 7 != 0) cells.add(null);

    final monthKey = _toMonthDocId(viewMonth);
    final hasData  = monthly.containsKey(monthKey);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x121565C0),
              blurRadius: 14,
              offset: Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────
            Container(
              color: _kBlueTint,
              padding: const EdgeInsets.symmetric(
                  horizontal: 4, vertical: 6),
              child: Row(
                children: [
                  IconButton(
                    onPressed: onPrev,
                    icon: const Icon(Icons.chevron_left_rounded,
                        color: _kBlue, size: 28),
                  ),
                  Expanded(
                    child: Text(
                      DateFormat('MMMM yyyy').format(viewMonth),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  IconButton(
                    onPressed: onNext,
                    icon: const Icon(Icons.chevron_right_rounded,
                        color: _kBlue, size: 28),
                  ),
                ],
              ),
            ),

            // ── Day labels ────────────────────────────────────────────────
            Container(
              color: const Color(0xFFF0F4FF),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: ['Mon','Tue','Wed','Thu','Fri','Sat','Sun']
                    .map((d) => Expanded(
                          child: Text(d,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: (d == 'Sat' || d == 'Sun')
                                      ? const Color(0xFFFF8C00)
                                      : const Color(0xFF6B7280))),
                        ))
                    .toList(),
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE8EEFF)),

            // ── No data notice ─────────────────────────────────────────────
            if (!hasData)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No attendance data for this month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade400),
                ),
              ),

            // ── Grid ──────────────────────────────────────────────────────
            if (hasData)
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 10, 6, 14),
                child: Column(
                  children: List.generate(cells.length ~/ 7, (row) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: List.generate(7, (col) {
                          final dt = cells[row * 7 + col];
                          if (dt == null) {
                            return const Expanded(
                                child: SizedBox(height: 38));
                          }
                          final key       = _norm(dt);
                          final status    = dayStatus[key];
                          final isToday   = key == today;
                          final isWeekend = col >= 5;

                          return Expanded(
                            child: _DayCell(
                              day      : dt.day,
                              status   : status,
                              isToday  : isToday,
                              isWeekend: isWeekend,
                            ),
                          );
                        }),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DAY CELL
// ─────────────────────────────────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final String? status; // "present" | "absent" | null
  final bool isToday;
  final bool isWeekend;

  const _DayCell({
    required this.day,
    required this.status,
    required this.isToday,
    required this.isWeekend,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;
    FontWeight fw;
    BoxBorder? border;

    if (status == 'present') {
      bg        = Colors.green.shade500;
      textColor = Colors.white;
      fw        = FontWeight.w700;
      border    = null;
    } else if (status == 'absent') {
      bg        = Colors.red.shade400;
      textColor = Colors.white;
      fw        = FontWeight.w700;
      border    = null;
    } else if (isToday) {
      bg        = _kBlueTint;
      textColor = _kBlue;
      fw        = FontWeight.w800;
      border    = Border.all(color: _kBlue, width: 2);
    } else {
      bg        = Colors.transparent;
      textColor = isWeekend
          ? const Color(0xFFFF8C00)
          : const Color(0xFF444444);
      fw        = FontWeight.w500;
      border    = null;
    }

    return Center(
      child: Container(
        width : 34,
        height: 34,
        decoration: BoxDecoration(
          color : bg,
          shape : BoxShape.circle,
          border: border,
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
                fontSize: 13, fontWeight: fw, color: textColor),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURRENT MONTH CARD
// ─────────────────────────────────────────────────────────────────────────────
class _CurrentMonthCard extends StatelessWidget {
  final int present, absent, total;
  const _CurrentMonthCard(
      {required this.present, required this.absent, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x141565C0),
              blurRadius: 12,
              offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                    color: _kBlueTint,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _kBlue),
                ),
              ),
              const Spacer(),
              const Icon(Icons.calendar_month_rounded,
                  color: _kBlue, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _tile(Icons.check_circle_rounded, 'Present',
                      present, Colors.green.shade600, Colors.green.shade50)),
              const SizedBox(width: 10),
              Expanded(
                  child: _tile(Icons.cancel_rounded, 'Absent',
                      absent, Colors.red.shade500, Colors.red.shade50)),
              const SizedBox(width: 10),
              Expanded(
                  child: _tile(Icons.event_rounded, 'Total',
                      total, _kBlue, _kBlueTint)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(IconData icon, String label, int val, Color c, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(
          children: [
            Icon(icon, color: c, size: 24),
            const SizedBox(height: 6),
            Text('$val',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w800, color: c)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF6B7280))),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// MONTHLY RECORD CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MonthCard extends StatelessWidget {
  final String monthId;
  final int present, absent, total;

  const _MonthCard({
    required this.monthId,
    required this.present,
    required this.absent,
    required this.total,
  });

  bool get _isCurrent {
    final now = DateTime.now();
    final dt  = _parseMonthDocId(monthId);
    return dt != null && dt.year == now.year && dt.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isCurrent ? _kBlue : _kBorder,
              width: _isCurrent ? 1.8 : 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F1565C0),
                blurRadius: 8,
                offset: Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.calendar_month_rounded,
                      color: _kBlue, size: 18),
                ),
                const SizedBox(width: 10),
                Text(_prettyMonth(monthId),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E))),
                if (_isCurrent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: _kBlueTint,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text('Current',
                        style: TextStyle(
                            fontSize: 10,
                            color: _kBlue,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            if (total > 0) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Row(
                  children: [
                    if (present > 0)
                      Expanded(
                          flex: present,
                          child: Container(
                              height: 8, color: Colors.green.shade400)),
                    if (absent > 0)
                      Expanded(
                          flex: absent,
                          child: Container(
                              height: 8, color: Colors.red.shade300)),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              children: [
                Expanded(
                    child: _badge(Icons.check_circle_rounded,
                        '$present days', 'Present',
                        Colors.green.shade600, Colors.green.shade50)),
                const SizedBox(width: 8),
                Expanded(
                    child: _badge(Icons.cancel_rounded,
                        '$absent days', 'Absent',
                        Colors.red.shade500, Colors.red.shade50)),
                const SizedBox(width: 8),
                Expanded(
                    child: _badge(Icons.event_rounded,
                        '$total days', 'Total', _kBlue, _kBlueTint)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(IconData icon, String value, String label,
      Color color, Color bg) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
            color: bg, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: Color(0xFF6B7280))),
          ],
        ),
      );
}