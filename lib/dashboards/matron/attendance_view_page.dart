import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendanceViewPage extends StatelessWidget {
  const AttendanceViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final monthKey = DateFormat('yyyy-MM').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('attendance')
            .doc(monthKey)
            .collection('records')
            .orderBy('room')
            .snapshots(),
        builder: (_, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (s.data!.docs.isEmpty) {
            return const Center(child: Text("No attendance records"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: s.data!.docs.map((d) {
              final r = d.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3A6B52),
                    child: Text(
                      r['room'].toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(r['name']),
                  subtitle:
                      Text("Attendance: ${r['present']} / ${r['total']}"),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
