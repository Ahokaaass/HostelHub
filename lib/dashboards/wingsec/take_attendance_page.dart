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
const _kPresent   = Color(0xFF2E7D32);
const _kAbsent    = Color(0xFFC62828);
const _kMess      = Color(0xFFF57C00);

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  bool _isSaving    = false;
  bool _locked      = false;
  bool _alreadyMarked = false;
  bool _checking    = true;

  DateTime _selectedDate = DateTime.now();
  final Map<String, Map<String, dynamic>> _localAttendance = {};

  String get _today    => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _monthKey => DateFormat('yyyy-MM').format(_selectedDate);
  String get _displayDate => DateFormat('MMMM d, yyyy').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _checkLockAndMarked();
  }

  // ── Check if locked / already marked ────────────────────────────────────────
  Future<void> _checkLockAndMarked() async {
    setState(() => _checking = true);
    try {
      final doc = await FirebaseFirestore.instance
          .collection('attendance')
          .doc(_monthKey)
          .get();
      final locked = doc.exists && doc.data()?['locked'] == true;
      final marked = await _attendanceExists();
      setState(() {
        _locked       = locked;
        _alreadyMarked = marked;
        _checking     = false;
      });
    } catch (_) {
      setState(() => _checking = false);
    }
  }

  Future<bool> _attendanceExists() async {
    final snap = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(_monthKey)
        .collection('records')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return false;
    final day = await snap.docs.first.reference
        .collection('days')
        .doc(_today)
        .get();
    return day.exists;
  }

  // ── Date picker ──────────────────────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kBlue)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _localAttendance.clear();
      });
      _checkLockAndMarked();
    }
  }

  // ══════════════════════════════════════════════════════════════════════
  // CRITICAL FIX: WriteBatch replaces sequential awaits
  // Old code: N students × 3 sequential Firestore calls = very slow
  // New code: 1 batch commit = all writes in a single network round-trip
  // ══════════════════════════════════════════════════════════════════════
  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);
    try {
      // Double-check not already marked
      if (await _attendanceExists()) {
        _showSnack('Attendance for $_displayDate already submitted', isError: true);
        setState(() { _alreadyMarked = true; _isSaving = false; });
        return;
      }

      final db       = FirebaseFirestore.instance;
      final monthRef = db.collection('attendance').doc(_monthKey);

      // Ensure month doc exists (non-batched — just metadata)
      await monthRef.set({'locked': false}, SetOptions(merge: true));

      // ── BATCH 1: Write all day docs + record metadata ─────────────────
      final batch1 = db.batch();
      for (final e in _localAttendance.entries) {
        final recordRef = monthRef.collection('records').doc(e.key);
        final dayRef    = recordRef.collection('days').doc(_today);

        batch1.set(recordRef, {
          'name': e.value['name'],
          'room': e.value['room'],
        }, SetOptions(merge: true));

        batch1.set(dayRef, {
          'status' : e.value['status'],
          'messCut': e.value['messCut'],
          'date'   : _today,
        });
      }
      await batch1.commit(); // ✅ single network call

      // ── BATCH 2: Recalculate totals for each student ──────────────────
      // Fetch all day-counts in parallel instead of sequentially
      final futures = _localAttendance.keys.map((id) async {
        final recordRef = monthRef.collection('records').doc(id);
        final days      = await recordRef.collection('days').get();
        final total     = days.docs.length;
        final present   = days.docs
            .where((d) => (d.data())['status'] == 'present')
            .length;
        return MapEntry(recordRef, {'total': total, 'present': present});
      });

      final results = await Future.wait(futures); // ✅ parallel fetch

      final batch2 = db.batch();
      for (final entry in results) {
        batch2.set(entry.key, entry.value, SetOptions(merge: true));
      }
      await batch2.commit(); // ✅ single network call

      if (!mounted) return;
      _showSnack('Attendance saved for $_displayDate ✓');
      setState(() {
        _alreadyMarked = true;
        _localAttendance.clear();
      });
    } catch (e) {
      if (mounted) _showSnack('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── Confirm dialog ────────────────────────────────────────────────────────
  Future<void> _confirmAndSave() async {
    final present = _localAttendance.values
        .where((d) => d['status'] == 'present').length;
    final absent  = _localAttendance.values
        .where((d) => d['status'] == 'absent').length;
    final mess    = _localAttendance.values
        .where((d) => d['messCut'] == true).length;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Submission',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      color: _kBlue, size: 16),
                  const SizedBox(width: 8),
                  Text(_displayDate,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color     : _kBlue,
                          fontSize  : 13)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _summaryRow('Present', present, _kPresent),
            const SizedBox(height: 8),
            _summaryRow('Absent',  absent,  _kAbsent),
            const SizedBox(height: 8),
            _summaryRow('Mess Cut', mess,   _kMess),
          ],
        ),
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
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
    if (confirm == true) await _saveAttendance();
  }

  Widget _summaryRow(String label, int count, Color color) => Row(
        children: [
          Container(
              width : 10,
              height: 10,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 13, color: _kText)),
          const Spacer(),
          Text('$count',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 14,
                  color     : color)),
        ],
      );

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white,
          size : 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: isError ? _kAbsent : _kPresent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ════════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),
          if (_checking)
            const Expanded(
                child: Center(
                    child: CircularProgressIndicator(color: _kBlue)))
          else if (_locked)
            _buildStatusState(
              icon      : Icons.lock_rounded,
              iconColor : Colors.grey.shade600,
              iconBg    : Colors.grey.shade100,
              title     : 'Attendance Locked',
              subtitle  : 'This month\'s records are locked and cannot be edited.',
            )
          else if (_alreadyMarked)
            _buildStatusState(
              icon      : Icons.check_circle_rounded,
              iconColor : _kPresent,
              iconBg    : const Color(0xFFE8F5E9),
              title     : 'Already Submitted',
              subtitle  : 'Attendance for $_displayDate has already been marked.',
            )
          else
            _buildStudentList(),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Take Attendance',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Mark daily student attendance',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  // Date picker button
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat('MMM d').format(_selectedDate),
                            style: const TextStyle(
                                color     : Colors.white,
                                fontSize  : 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.today_rounded,
                        color: Colors.white70, size: 14),
                    const SizedBox(width: 6),
                    Text(_displayDate,
                        style: const TextStyle(
                            color     : Colors.white,
                            fontSize  : 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Status state (locked / already marked) ────────────────────────────────
  Widget _buildStatusState({
    required IconData icon,
    required Color    iconColor,
    required Color    iconBg,
    required String   title,
    required String   subtitle,
  }) =>
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width : 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(24)),
                  child: Icon(icon, size: 40, color: iconColor),
                ),
                const SizedBox(height: 20),
                Text(title,
                    style: const TextStyle(
                        fontSize  : 18,
                        fontWeight: FontWeight.w800,
                        color     : _kText)),
                const SizedBox(height: 8),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13, color: _kSubtext)),
              ],
            ),
          ),
        ),
      );

  // ── Student list ──────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _kBlue));
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width : 64,
                    height: 64,
                    decoration: BoxDecoration(
                        color       : _kBlueTint,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.people_outline_rounded,
                        color: _kBlue, size: 32),
                  ),
                  const SizedBox(height: 14),
                  const Text('No students found',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color     : _kText)),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Legend / count bar ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color       : _kBlueTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${students.length} Students',
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

              // ── Cards ───────────────────────────────────────────────
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                  itemCount: students.length,
                  itemBuilder: (_, i) {
                    final id = students[i].id;
                    final s  = students[i].data()
                        as Map<String, dynamic>;
                    _localAttendance.putIfAbsent(id, () => {
                          'name'   : s['name'] ?? 'Unknown',
                          'room'   : s['room'],
                          'status' : 'present',
                          'messCut': false,
                        });
                    return _StudentCard(
                      studentId: id,
                      data     : _localAttendance[id]!,
                      onChanged: () => setState(() {}),
                    );
                  },
                ),
              ),

              // ── Submit button ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
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
                child: _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: _kBlue))
                    : ElevatedButton.icon(
                        onPressed: _confirmAndSave,
                        icon : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 20),
                        label: const Text('Submit Attendance',
                            style: TextStyle(
                                fontSize  : 15,
                                fontWeight: FontWeight.w700)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kBlue,
                          foregroundColor: Colors.white,
                          minimumSize:
                              const Size(double.infinity, 54),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14)),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(
            horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color       : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border      : Border.all(color: color.withOpacity(0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 12,
                color     : color)),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// STUDENT CARD — extracted widget, no avatar circle, overflow safe
// ─────────────────────────────────────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final String studentId;
  final Map<String, dynamic> data;
  final VoidCallback onChanged;

  const _StudentCard({
    required this.studentId,
    required this.data,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final name    = data['name'] as String;
    final room    = data['room']?.toString() ?? '-';
    final status  = data['status'] as String;
    final messCut = data['messCut'] as bool;

    final isPresent = status == 'present';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPresent
              ? const Color(0xFF2E7D32).withOpacity(0.25)
              : const Color(0xFFC62828).withOpacity(0.25),
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
            // ── Name + room (no avatar, no overflow) ────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines : 1,
                    overflow : TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                        color     : _kText),
                  ),
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

            // ── P / A toggle ────────────────────────────────────────
            _PAToggle(
              status   : status,
              onChanged: (val) {
                data['status'] = val;
                onChanged();
              },
            ),
            const SizedBox(width: 8),

            // ── Mess cut ─────────────────────────────────────────────
            GestureDetector(
              onTap: () {
                data['messCut'] = !messCut;
                onChanged();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width : 36,
                height: 36,
                decoration: BoxDecoration(
                  color: messCut
                      ? const Color(0xFFF57C00).withOpacity(0.12)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: messCut
                        ? const Color(0xFFF57C00)
                        : const Color(0xFFE5E7EB),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text('M',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize  : 13,
                          color     : messCut
                              ? const Color(0xFFF57C00)
                              : _kSubtext)),
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
          _pill('P', const Color(0xFF2E7D32), status == 'present',
              () => onChanged('present')),
          _pill('A', const Color(0xFFC62828), status == 'absent',
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