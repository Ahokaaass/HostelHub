import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ViewAttendancePage extends StatefulWidget {
  const ViewAttendancePage({super.key});

  @override
  State<ViewAttendancePage> createState() => _ViewAttendancePageState();
}

class _ViewAttendancePageState extends State<ViewAttendancePage> {
  String? _selectedMonth; // yyyy-MM

  @override
  Widget build(BuildContext context) {
    return _selectedMonth == null
        ? _monthSelectionUI()
        : _attendanceViewUI();
  }

  // =====================================================
  // 1️⃣ MONTH SELECTION SCREEN
  // =====================================================
  Widget _monthSelectionUI() {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Attendance"),
        backgroundColor: const Color(0xFF3A6B52),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance') // ✅ CORRECT COLLECTION
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No attendance records available"),
            );
          }

          final months = snapshot.data!.docs
              .map((d) => d.id)
              .toList()
            ..sort();

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select month to view attendance",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedMonth,
                  items: months.map((m) {
                    final dt = DateTime.parse("$m-01");
                    return DropdownMenuItem(
                      value: m,
                      child: Text(DateFormat('MMMM yyyy').format(dt)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() => _selectedMonth = val);
                  },
                  decoration: const InputDecoration(
                    labelText: "Month",
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // =====================================================
  // 2️⃣ ATTENDANCE VIEW SCREEN
  // =====================================================
  Widget _attendanceViewUI() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('attendance') // ✅ CORRECT
          .doc(_selectedMonth)
          .snapshots(),
      builder: (context, monthSnap) {
        bool isLocked = monthSnap.hasData &&
            monthSnap.data!.exists &&
            (monthSnap.data!.data() as Map)['locked'] == true;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() => _selectedMonth = null);
              },
            ),
            title: Text("Records: $_selectedMonth"),
            backgroundColor: const Color(0xFF3A6B52),
            foregroundColor: Colors.white,
            actions: [
              if (isLocked)
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  onPressed: () => _generatePDF(_selectedMonth!),
                ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('attendance')
                .doc(_selectedMonth)
                .collection('records')
                .orderBy('room')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final records = snapshot.data!.docs;

              return Column(
                children: [
                  if (isLocked) _lockBanner(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, i) {
                        final d =
                            records[i].data() as Map<String, dynamic>;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF3A6B52),
                              child: Text(
                                d['room'].toString(),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              d['name'],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                                "Attendance: ${d['present'] ?? 0} / ${d['total'] ?? 0}"),
                            trailing: isLocked
                                ? const Icon(Icons.lock_outline,
                                    color: Colors.grey)
                                : const Icon(Icons.check_circle,
                                    color: Colors.green),
                          ),
                        );
                      },
                    ),
                  ),
                  if (!isLocked && records.isNotEmpty)
                    _finalSubmitButton(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // =====================================================
  // COMMON WIDGETS
  // =====================================================
  Widget _lockBanner() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.orange.shade100,
        child: const Text(
          "🔒 Records Locked. PDF Report available in menu.",
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );

  Widget _finalSubmitButton() => Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            minimumSize: const Size(double.infinity, 50),
          ),
          onPressed: _confirmFinalSubmit,
          child: const Text(
            "FINAL SUBMIT & LOCK",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );

  // =====================================================
  // LOCK MONTH
  // =====================================================
  Future<void> _confirmFinalSubmit() async {
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Lock Records?"),
        content:
            const Text("Once submitted, you cannot edit this month anymore."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Confirm")),
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

  // =====================================================
  // PDF
  // =====================================================
  Future<void> _generatePDF(String key) async {
    final pdf = pw.Document();
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
              "Monthly Attendance Report - $key",
              style: pw.TextStyle(
                  fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          pw.Table.fromTextArray(
            headers: ['Room', 'Name', 'Present', 'Total', 'Percentage'],
            data: snapshot.docs.map((doc) {
              final d = doc.data();
              final perc = (d['present'] / d['total']) * 100;
              return [
                d['room'],
                d['name'],
                d['present'],
                d['total'],
                "${perc.toStringAsFixed(1)}%"
              ];
            }).toList(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
        onLayout: (format) async => pdf.save());
  }
}
