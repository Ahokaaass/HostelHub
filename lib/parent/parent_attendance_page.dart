import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student/student_data.dart';

class ParentAttendancePage extends StatelessWidget {
  const ParentAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Attendance"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('attendance')
            .doc('2026-01')
            .collection('records')
            .doc(StudentData.admissionNo)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("No attendance data"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final present = data['present'] ?? 0;
          final total = data['total'] ?? 0;
          final absent = total - present;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Month: 2026-01",
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text("Name: ${StudentData.name}"),
                        Text("Room: ${StudentData.room}"),
                        const SizedBox(height: 10),
                        Text("Attendance: $present / $total"),
                        const SizedBox(height: 12),
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          children: [
                            const TableRow(children: [
                              Center(child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Text("Present"),
                              )),
                              Center(child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Text("Absent"),
                              )),
                              Center(child: Padding(
                                padding: EdgeInsets.all(6),
                                child: Text("Total"),
                              )),
                            ]),
                            TableRow(children: [
                              Center(child: Text("$present",
                                  style:
                                      const TextStyle(color: Colors.green))),
                              Center(child: Text("$absent",
                                  style:
                                      const TextStyle(color: Colors.red))),
                              Center(child: Text("$total")),
                            ]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
