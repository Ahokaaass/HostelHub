import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TakeAttendancePage extends StatefulWidget {
  const TakeAttendancePage({super.key});

  @override
  State<TakeAttendancePage> createState() => _TakeAttendancePageState();
}

class _TakeAttendancePageState extends State<TakeAttendancePage> {
  bool _isSaving = false;
  bool _locked = false;

  DateTime _selectedDate = DateTime.now();

  final Map<String, dynamic> _localAttendance = {};

  // 🔹 Dynamic keys (DO NOT CHANGE)
  String get _today => DateFormat('yyyy-MM-dd').format(_selectedDate);
  String get _monthKey => DateFormat('yyyy-MM').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _checkLock();
  }

  // 🔒 Check lock ONLY for selected month
  Future<void> _checkLock() async {
    final doc = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(_monthKey)
        .get();

    setState(() {
      _locked = doc.exists && doc.data()?['locked'] == true;
    });
  }

  // 📅 Pick date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _localAttendance.clear();
      });
      _checkLock();
    }
  }

  // ✅ Check if attendance already exists for that day
  Future<bool> _attendanceExists() async {
    final snap = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(_monthKey)
        .collection('records')
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;

    final dayCheck = await FirebaseFirestore.instance
        .collection('attendance')
        .doc(_monthKey)
        .collection('records')
        .doc(snap.docs.first.id)
        .collection('days')
        .doc(_today)
        .get();

    return dayCheck.exists;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Take Attendance • $_today"),
        backgroundColor: const Color(0xFF3A6B52),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDate,
          ),
        ],
      ),
      body: _locked
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text("Attendance locked for this month"),
                ],
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .where('role', isEqualTo: 'student')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final students = snapshot.data!.docs;

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, i) {
                          final id = students[i].id;
                          final s = students[i].data() as Map<String, dynamic>;

                          _localAttendance.putIfAbsent(id, () => {
                                'name': s['name'],
                                'room': s['room'],
                                'status': 'present',
                                'messCut': false,
                              });

                          final d = _localAttendance[id];

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${d['name']} (Room ${d['room'] ?? '-'})",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),

                                  /// ✅ OVERFLOW FIXED UI
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        children: [
                                          ChoiceChip(
                                            label: const Text("Present"),
                                            selected:
                                                d['status'] == 'present',
                                            onSelected: (_) => setState(
                                                () => d['status'] = 'present'),
                                          ),
                                          ChoiceChip(
                                            label: const Text("Absent"),
                                            selected:
                                                d['status'] == 'absent',
                                            onSelected: (_) => setState(
                                                () => d['status'] = 'absent'),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Text("Mess Cut"),
                                          const SizedBox(width: 8),
                                          Switch(
                                            value: d['messCut'],
                                            onChanged: (v) => setState(
                                                () => d['messCut'] = v),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3A6B52),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                        onPressed: _isSaving ? null : _saveAttendance,
                        child: _isSaving
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("SAVE ATTENDANCE"),
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }

  // 💾 SAVE LOGIC (FULLY CORRECTED)
  Future<void> _saveAttendance() async {
    setState(() => _isSaving = true);

    try {
      final exists = await _attendanceExists();

      if (exists) {
        bool? confirm = await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Attendance Exists"),
            content: Text(
                "Attendance for $_today already exists. Do you want to overwrite it?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Overwrite")),
            ],
          ),
        );

        if (confirm != true) {
          setState(() => _isSaving = false);
          return;
        }
      }

      final db = FirebaseFirestore.instance;
      final monthRef = db.collection('attendance').doc(_monthKey);

      await monthRef.set({'locked': false}, SetOptions(merge: true));

      for (final e in _localAttendance.entries) {
        final recordRef = monthRef.collection('records').doc(e.key);
        final dayRef = recordRef.collection('days').doc(_today);

        await recordRef.set({
          'name': e.value['name'],
          'room': e.value['room'],
        }, SetOptions(merge: true));

        await dayRef.set({
          'status': e.value['status'],
          'messCut': e.value['messCut'],
          'date': _today,
        });
      }

      for (final e in _localAttendance.entries) {
        final recordRef = monthRef.collection('records').doc(e.key);
        final days = await recordRef.collection('days').get();

        final total = days.docs.length;
        final present =
            days.docs.where((d) => d['status'] == 'present').length;

        await recordRef.set({
          'total': total,
          'present': present,
        }, SetOptions(merge: true));
      }

      _showDialog("Success", "Attendance saved for $_today");

      /// 🔁 AUTO MOVE TO NEXT DAY
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 1));
        _localAttendance.clear();
      });
      _checkLock();
    } catch (e) {
      _showDialog("Error", e.toString());
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _showDialog(String t, String m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t),
        content: Text(m),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"))
        ],
      ),
    );
  }
}
