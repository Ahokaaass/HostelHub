import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentRecordsPage extends StatelessWidget {
  const StudentRecordsPage({super.key});

  // ================= CSV UPLOAD =================
  Future<void> _uploadCSV(BuildContext context) async {
    try {
      // Pick CSV file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) return;

      final file = File(result.files.single.path!);
      final csvString = await file.readAsString();

      final rows = const CsvToListConverter().convert(csvString);

      // Skip header row (row 0)
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        final studentName = row[0].toString();
        final admissionNo = row[1].toString();
        final email = row[2].toString();
        final phone = row[3].toString();
        final department = row[4].toString();
        final semester = row[5].toString();
        final parentName = row[6].toString();
        final parentPhone = row[7].toString();
        final parentEmail = row[8].toString();
        final ktuid = row[9].toString();
        final dateOfAdmission = row[10].toString();

        // Generate password
        final last4 = phone.substring(phone.length - 4);
        final password = "student@$last4";

        await FirebaseFirestore.instance
            .collection('users')
            .doc(admissionNo)
            .set({
          // Student details
          "name": studentName,
          "admissionNo": admissionNo,
          "email": email,
          "phone": phone,
          "department": department,
          "semester": semester,
          "parentName": parentName,
          "parentPhone": parentPhone,
          "parentEmail": parentEmail,
          "ktuid": ktuid,
          "dateOfAdmission": dateOfAdmission,

          // Login credentials
          "userId": admissionNo,
          "password": password,
          "isFirstLogin": true,

          // Role info
          "role": "student",
          "isHostelSecretary": false,
          "isWingSecretary": false,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Students uploaded successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Records"),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () => _uploadCSV(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'student')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No students found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final s = snapshot.data!.docs[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  title: Text(s['name']),
                  subtitle: Text(
                    "Admission: ${s['admissionNo']}\n"
                    "Dept: ${s['department']} | ${s['semester']}\n"
                    "KTU ID: ${s['ktuid']}",
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
