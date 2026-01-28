import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../student/student_data.dart';

class StudentAttendancePage extends StatelessWidget {
  const StudentAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final admissionNo = StudentData.admissionNo;

    return Scaffold(
      appBar: AppBar(title: const Text("My Attendance")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .snapshots(),
        builder: (context, monthSnapshot) {
          if (!monthSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final months = monthSnapshot.data!.docs;

          if (months.isEmpty) {
            return const Center(child: Text("No attendance records"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: months.length,
            itemBuilder: (context, index) {
              final monthId = months[index].id;

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('attendance')
                    .doc(monthId)
                    .collection('records')
                    .doc(admissionNo)
                    .snapshots(),
                builder: (context, recordSnap) {
                  if (!recordSnap.hasData || !recordSnap.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                      recordSnap.data!.data() as Map<String, dynamic>;

                  final int present = data['present'] ?? 0;
                  final int total = data['total'] ?? 0;
                  final int absent = total - present;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ===== HEADER =====
                          Text(
                            "Month: $monthId",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),

                          Text("Name: ${data['name']}"),
                          Text("Room: ${data['room']}"),

                          const SizedBox(height: 10),

                          // ===== SUMMARY =====
                          Row(
                            children: [
                              Text(
                                "Attendance: ",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "$present / $total",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ===== TABLE =====
                          Table(
                            border: TableBorder.all(
                                color: Colors.grey.shade300),
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  color: Color(0xFFEAF4EE),
                                ),
                                children: [
                                  _HeaderCell("Present"),
                                  _HeaderCell("Absent"),
                                  _HeaderCell("Total"),
                                ],
                              ),
                              TableRow(
                                children: [
                                  _ValueCell(
                                    present.toString(),
                                    Colors.green,
                                  ),
                                  _ValueCell(
                                    absent.toString(),
                                    Colors.red,
                                  ),
                                  _ValueCell(
                                    total.toString(),
                                    Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// ================= HELPER WIDGETS =================

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ValueCell extends StatelessWidget {
  final String text;
  final Color color;
  const _ValueCell(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
