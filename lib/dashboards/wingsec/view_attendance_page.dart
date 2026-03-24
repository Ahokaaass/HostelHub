import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);
const _kPresent   = Color(0xFF2E7D32);
const _kAbsent    = Color(0xFFC62828);
const _kMess      = Color(0xFFF57C00);

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HEADER WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final List<Widget> actions;

  const _GradientHeader({
    required this.title,
    required this.onBack,
    this.subtitle,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
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
              offset    : Offset(0, 6)),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (subtitle != null)
                      Text(subtitle!,
                          style: const TextStyle(
                              color  : Colors.white70,
                              fontSize: 12)),
                    Text(title,
                        style: const TextStyle(
                            color     : Colors.white,
                            fontSize  : 20,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3)),
                  ],
                ),
              ),
              ...actions,
            ],
          ),
        ),
      ),
    );
  }
}

Widget _headerIconBtn(IconData icon, String tooltip, VoidCallback onTap) =>
    Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(11),
            border:
                Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// VIEW ATTENDANCE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) =>
      _selectedMonth == null ? _monthSelectionUI() : _attendanceViewUI();

  // ══════════════════════════════════════════════════════════════
  // 1. MONTH SELECTION
  // ══════════════════════════════════════════════════════════════
  Widget _monthSelectionUI() {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _GradientHeader(
            title   : 'View Attendance',
            subtitle: 'Select a month',
            onBack  : () => Navigator.pop(context),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('attendance')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: _kBlue));
                }
                if (snapshot.data!.docs.isEmpty) {
                  return _emptyState(
                      'No attendance records available');
                }

                final months = snapshot.data!.docs
                    .map((d) => d.id)
                    .toList()
                  ..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                      20, 24, 20, 36),
                  itemCount: months.length,
                  itemBuilder: (_, i) {
                    final m  = months[i];
                    final dt = DateTime.parse('$m-01');
                    return _MonthCard(
                      label   : DateFormat('MMMM yyyy').format(dt),
                      monthKey: m,
                      onTap   : () =>
                          setState(() => _selectedMonth = m),
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

  // ══════════════════════════════════════════════════════════════
  // 2. RECORDS VIEW
  // ══════════════════════════════════════════════════════════════
  Widget _attendanceViewUI() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance')
          .doc(_selectedMonth)
          .snapshots(),
      builder: (context, monthSnap) {
        final isLocked = monthSnap.hasData &&
            monthSnap.data!.exists &&
            (monthSnap.data!.data() as Map?)?['locked'] == true;

        final dt    = DateTime.parse('$_selectedMonth-01');
        final title = DateFormat('MMMM yyyy').format(dt);

        return Scaffold(
          backgroundColor: _kBg,
          body: Column(
            children: [
              _GradientHeader(
                title   : title,
                subtitle: 'Attendance Records',
                onBack  : () =>
                    setState(() => _selectedMonth = null),
                actions : [
                  _headerIconBtn(
                    isLocked
                        ? Icons.edit_off_rounded
                        : Icons.edit_calendar_rounded,
                    isLocked ? 'Editing Locked' : 'Edit Day',
                    () => _openEditDayPicker(isLocked),
                  ),
                  _headerIconBtn(
                    Icons.picture_as_pdf_rounded,
                    'Download PDF',
                    () => _generatePDF(_selectedMonth!),
                  ),
                ],
              ),

              if (isLocked) _lockBanner(),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('attendance')
                      .doc(_selectedMonth)
                      .collection('records')
                      .orderBy('room')
                      .snapshots(),
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: _kBlue));
                    }
                    final records = snap.data!.docs;
                    if (records.isEmpty) {
                      return _emptyState(
                          'No records found for this month');
                    }

                    return Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(
                                16, 20, 16, 16),
                            itemCount: records.length,
                            itemBuilder: (_, i) {
                              final d = records[i].data()
                                  as Map<String, dynamic>;
                              final present  = d['present'] ?? 0;
                              final total    = d['total']   ?? 0;
                              final name = (d['name'] as String?) ??
                                  'Unknown';
                              final room =
                                  d['room']?.toString() ?? '-';

                              return _ViewRecordCard(
                                name   : name,
                                room   : room,
                                present: present,
                                total  : total,
                              );
                            },
                          ),
                        ),
                        if (!isLocked) _finalSubmitButton(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Lock banner ────────────────────────────────────────────────────────────
  Widget _lockBanner() => Container(
        width  : double.infinity,
        padding: const EdgeInsets.symmetric(
            vertical: 10, horizontal: 20),
        color: Colors.orange.shade50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_rounded,
                size : 15,
                color: Colors.orange.shade800),
            const SizedBox(width: 8),
            Text(
              'Records are locked. Editing is disabled.',
              style: TextStyle(
                  color     : Colors.orange.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize  : 13),
            ),
          ],
        ),
      );

  // ── Final submit / lock button ────────────────────────────────────────────
  Widget _finalSubmitButton() => Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 26),
        decoration: BoxDecoration(
          color: _kBg,
          boxShadow: [
            BoxShadow(
              color     : Colors.black.withOpacity(0.07),
              blurRadius: 16,
              offset    : const Offset(0, -4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: _confirmFinalSubmit,
          icon : const Icon(Icons.lock_rounded, size: 18),
          label: const Text('Final Submit & Lock',
              style: TextStyle(
                  fontSize  : 15,
                  fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            minimumSize    : const Size(double.infinity, 52),
            elevation      : 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );

  // ── Confirm lock ──────────────────────────────────────────────────────────
  Future<void> _confirmFinalSubmit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Lock Records?',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: const Text(
            'Once locked, attendance for this month cannot be edited. This action is permanent.',
            style: TextStyle(color: _kSubtext, fontSize: 14)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
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
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Lock'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance
          .collection('attendance')
          .doc(_selectedMonth)
          .set({'locked': true}, SetOptions(merge: true));
    }
  }

  // ── Edit day picker ────────────────────────────────────────────────────────
  void _openEditDayPicker(bool isLocked) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.lock_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Editing not possible — attendance is locked.'),
        ]),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    final dt          = DateTime.parse('$_selectedMonth-01');
    final daysInMonth = DateUtils.getDaysInMonth(dt.year, dt.month);

    showModalBottomSheet(
      context            : context,
      isScrollControlled : true,
      backgroundColor    : Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize    : 0.4,
        maxChildSize    : 0.85,
        expand          : false,
        builder: (__, scrollCtrl) => Container(
          decoration: const BoxDecoration(
            color        : Colors.white,
            borderRadius : BorderRadius.vertical(
                top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width : 40,
                height: 4,
                decoration: BoxDecoration(
                  color       : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    const Text('Select a Day to Edit',
                        style: TextStyle(
                            fontSize  : 17,
                            fontWeight: FontWeight.w800,
                            color     : _kText)),
                    const Spacer(),
                    Text(DateFormat('MMMM yyyy').format(dt),
                        style: const TextStyle(
                            fontSize: 13, color: _kSubtext)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount  : 7,
                    mainAxisSpacing : 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: daysInMonth,
                  itemBuilder: (_, i) {
                    final day    = i + 1;
                    final dayKey =
                        '$_selectedMonth-${day.toString().padLeft(2, '0')}';
                    final isPast =
                        DateTime(dt.year, dt.month, day)
                            .isBefore(DateTime.now());

                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditDayAttendancePage(
                              monthKey: _selectedMonth!,
                              dayKey  : dayKey,
                              dayLabel: DateFormat('MMM d, yyyy')
                                  .format(DateTime.parse(dayKey)),
                            ),
                          ),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        decoration: BoxDecoration(
                          color: isPast ? _kBlueTint : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPast ? _kBorder : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Center(
                          child: Text('$day',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize  : 13,
                                  color     : isPast
                                      ? _kBlue
                                      : _kSubtext)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PDF ────────────────────────────────────────────────────────────────────
  Future<void> _generatePDF(String key) async {
    final pdf      = pw.Document();
    final snapshot = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(key)
        .collection('records')
        .orderBy('room')
        .get();

    pdf.addPage(
      pw.MultiPage(
        build: (_) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              'Monthly Attendance Report — $key',
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Room', 'Name', 'Present', 'Total', 'Percentage'],
            data: snapshot.docs.map((doc) {
              final d       = doc.data();
              final present = d['present'] ?? 0;
              final total   = d['total']   ?? 1;
              final perc    = (present / total) * 100;
              return [
                d['room']?.toString() ?? '-',
                d['name'] ?? '-',
                present.toString(),
                total.toString(),
                '${perc.toStringAsFixed(1)}%',
              ];
            }).toList(),
          ),
        ],
      ),
    );
    await Printing.layoutPdf(onLayout: (_) async => pdf.save());
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW RECORD CARD — no avatar, overflow safe
// ─────────────────────────────────────────────────────────────────────────────
class _ViewRecordCard extends StatelessWidget {
  final String name;
  final String room;
  final int    present;
  final int    total;

  const _ViewRecordCard({
    required this.name,
    required this.room,
    required this.present,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border      : Border.all(color: _kBorder, width: 1.2),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0C1565C0),
              blurRadius: 8,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Room badge
          Container(
            width : 46,
            height: 46,
            decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(12)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Room',
                    style: TextStyle(
                        fontSize  : 9,
                        color     : _kSubtext,
                        fontWeight: FontWeight.w500)),
                Text(room,
                    style: const TextStyle(
                        fontSize  : 13,
                        fontWeight: FontWeight.w800,
                        color     : _kBlue)),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 14,
                    color     : _kText)),
          ),

          // Present / Total count only
          const SizedBox(width: 10),
          Text('$present/$total',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 15,
                  color     : _kText)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MONTH CARD
// ─────────────────────────────────────────────────────────────────────────────
class _MonthCard extends StatelessWidget {
  final String label;
  final String monthKey;
  final VoidCallback onTap;

  const _MonthCard({
    required this.label,
    required this.monthKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin : const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border      : Border.all(color: _kBorder, width: 1.2),
          boxShadow   : const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 8,
                offset    : Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width : 46,
              height: 46,
              decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.calendar_month_rounded,
                  color: _kBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize  : 15,
                      fontWeight: FontWeight.w700,
                      color     : _kText)),
            ),
            Container(
              width : 30,
              height: 30,
              decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.chevron_right_rounded,
                  color: _kBlue, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
Widget _emptyState(String msg) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width : 64,
            height: 64,
            decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.event_busy_rounded,
                color: _kBlue, size: 32),
          ),
          const SizedBox(height: 16),
          Text(msg,
              style: const TextStyle(
                  color     : _kText,
                  fontSize  : 15,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );

// ═════════════════════════════════════════════════════════════════════════════
// EDIT DAY ATTENDANCE PAGE
// ═════════════════════════════════════════════════════════════════════════════
class EditDayAttendancePage extends StatefulWidget {
  final String monthKey;
  final String dayKey;
  final String dayLabel;

  const EditDayAttendancePage({
    super.key,
    required this.monthKey,
    required this.dayKey,
    required this.dayLabel,
  });

  @override
  State<EditDayAttendancePage> createState() =>
      _EditDayAttendancePageState();
}

class _EditDayAttendancePageState
    extends State<EditDayAttendancePage> {
  final Map<String, Map<String, dynamic>> _edits = {};
  bool _isSaving = false;
  bool _loaded   = false;

  @override
  void initState() {
    super.initState();
    _loadDayAttendance();
  }

  Future<void> _loadDayAttendance() async {
    final records = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(widget.monthKey)
        .collection('records')
        .orderBy('room')
        .get();

    // ── Fetch all day docs in parallel — much faster than sequential ──
    final futures = records.docs.map((rec) async {
      final daySnap = await rec.reference
          .collection('days')
          .doc(widget.dayKey)
          .get();
      return MapEntry(rec, daySnap);
    });
    final results = await Future.wait(futures);

    for (final entry in results) {
      final rec     = entry.key;
      final daySnap = entry.value;
      final recData = rec.data();
      if (daySnap.exists) {
        final dayData = daySnap.data()!;
        _edits[rec.id] = {
          'name'   : recData['name'] ?? 'Unknown',
          'room'   : recData['room']?.toString() ?? '-',
          'status' : dayData['status']  ?? 'present',
          'messCut': dayData['messCut'] ?? false,
        };
      }
    }
    setState(() => _loaded = true);
  }

  // ── BATCH save — single commit instead of N sequential awaits ─────────────
  Future<void> _saveEdits() async {
    setState(() => _isSaving = true);
    try {
      final db       = FirebaseFirestore.instance;
      final monthRef = db.collection('attendance').doc(widget.monthKey);

      // ── BATCH 1: write all day docs ───────────────────────────────────
      final batch1 = db.batch();
      for (final e in _edits.entries) {
        final dayRef =
            monthRef.collection('records').doc(e.key)
                .collection('days').doc(widget.dayKey);
        batch1.set(dayRef, {
          'status' : e.value['status'],
          'messCut': e.value['messCut'],
          'date'   : widget.dayKey,
        });
      }
      await batch1.commit(); // ✅ single round-trip

      // ── Recalculate totals in parallel ────────────────────────────────
      final futures = _edits.keys.map((id) async {
        final recordRef = monthRef.collection('records').doc(id);
        final days      = await recordRef.collection('days').get();
        final total     = days.docs.length;
        final present   = days.docs
            .where((d) => (d.data())['status'] == 'present')
            .length;
        return MapEntry(recordRef, {'total': total, 'present': present});
      });
      final results = await Future.wait(futures); // ✅ parallel

      // ── BATCH 2: write totals ─────────────────────────────────────────
      final batch2 = db.batch();
      for (final e in results) {
        batch2.set(e.key, e.value, SetOptions(merge: true));
      }
      await batch2.commit(); // ✅ single round-trip

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Row(children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Attendance updated successfully!'),
        ]),
        backgroundColor: _kPresent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _GradientHeader(
            title   : widget.dayLabel,
            subtitle: 'Edit Attendance',
            onBack  : () => Navigator.pop(context),
          ),

          Expanded(
            child: !_loaded
                ? const Center(
                    child: CircularProgressIndicator(color: _kBlue))
                : _edits.isEmpty
                    ? _emptyState('No attendance found for this day')
                    : Column(
                        children: [
                          // ── Legend bar ──────────────────────────────
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20, 16, 20, 4),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: _kBlueTint,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${_edits.length} Students',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize  : 12,
                                        color     : _kBlue),
                                  ),
                                ),
                                const Spacer(),
                                _legendChip('P', _kPresent),
                                const SizedBox(width: 8),
                                _legendChip('A', _kAbsent),
                                const SizedBox(width: 8),
                                _legendChip('M', _kMess),
                              ],
                            ),
                          ),

                          // ── Cards ────────────────────────────────────
                          Expanded(
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                  16, 8, 16, 110),
                              children: _edits.entries.map((e) {
                                final id      = e.key;
                                final d       = e.value;
                                final status  = d['status'] as String;
                                final messCut = d['messCut'] as bool;

                                return _EditCard(
                                  name    : d['name'] as String,
                                  room    : d['room']  as String,
                                  status  : status,
                                  messCut : messCut,
                                  onStatusChanged: (val) =>
                                      setState(() =>
                                          _edits[id]!['status'] = val),
                                  onMessChanged: () => setState(() =>
                                      _edits[id]!['messCut'] =
                                          !messCut),
                                );
                              }).toList(),
                            ),
                          ),

                          // ── Save button ──────────────────────────────
                          Container(
                            padding: const EdgeInsets.fromLTRB(
                                16, 12, 16, 28),
                            decoration: BoxDecoration(
                              color: _kBg,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.07),
                                  blurRadius: 16,
                                  offset: const Offset(0, -4),
                                ),
                              ],
                            ),
                            child: _isSaving
                                ? const Center(
                                    child: CircularProgressIndicator(
                                        color: _kBlue))
                                : ElevatedButton.icon(
                                    onPressed: _saveEdits,
                                    icon : const Icon(
                                        Icons.save_rounded,
                                        size: 20),
                                    label: const Text('Save Changes',
                                        style: TextStyle(
                                            fontSize  : 15,
                                            fontWeight:
                                                FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _kBlue,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(
                                          double.infinity, 52),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(
                                                  14)),
                                    ),
                                  ),
                          ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _legendChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color       : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 12,
                color     : color)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT CARD — no avatar, overflow safe
// ─────────────────────────────────────────────────────────────────────────────
class _EditCard extends StatelessWidget {
  final String name;
  final String room;
  final String status;
  final bool   messCut;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback         onMessChanged;

  const _EditCard({
    required this.name,
    required this.room,
    required this.status,
    required this.messCut,
    required this.onStatusChanged,
    required this.onMessChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isPresent = status == 'present';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? _kPresent.withOpacity(0.25)
              : _kAbsent.withOpacity(0.25),
          width: 1.3,
        ),
        boxShadow: const [
          BoxShadow(
              color     : Color(0x0C1565C0),
              blurRadius: 8,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // Name + room — no avatar, overflow fixed
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 14,
                          color     : _kText)),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.meeting_room_rounded,
                          size: 11, color: _kSubtext),
                      const SizedBox(width: 3),
                      Text('Room $room',
                          style: const TextStyle(
                              fontSize: 12, color: _kSubtext)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // P/A toggle
            _PAToggle(
                status: status, onChanged: onStatusChanged),
            const SizedBox(width: 8),

            // Mess cut
            GestureDetector(
              onTap: onMessChanged,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width : 36,
                height: 36,
                decoration: BoxDecoration(
                  color: messCut
                      ? _kMess.withOpacity(0.12)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: messCut ? _kMess : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text('M',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize  : 13,
                          color     : messCut ? _kMess : _kSubtext)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// P / A TOGGLE
// ─────────────────────────────────────────────────────────────────────────────
class _PAToggle extends StatelessWidget {
  final String status;
  final ValueChanged<String> onChanged;

  const _PAToggle({required this.status, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color       : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border      : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pill('P', _kPresent, status == 'present',
              () => onChanged('present')),
          _pill('A', _kAbsent, status == 'absent',
              () => onChanged('absent')),
        ],
      ),
    );
  }

  Widget _pill(
      String label, Color color, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width : 36,
        height: 36,
        decoration: BoxDecoration(
          color       : selected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize  : 13,
                  color     : selected
                      ? Colors.white
                      : const Color(0xFFB0B8C1))),
        ),
      ),
    );
  }
}