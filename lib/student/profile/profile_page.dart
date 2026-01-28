import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile.dart';
import 'detail_sheet.dart';
// import '../student_data.dart';
import '../../screens/login_screen.dart';

class ProfilePage extends StatelessWidget {
  final String admissionNo;

  const ProfilePage({super.key, required this.admissionNo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(admissionNo)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 45,
                child: Icon(Icons.person, size: 45),
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  data['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(child: Text(data['email'])),

              const SizedBox(height: 24),

              _tile(context, "Personal Details", () {
                showDetailSheet(context, "Personal Details", [
                  {"label": "Admission No", "value": data['admissionNo']},
                  {"label": "Phone", "value": data['phone']},
                  {"label": "Department", "value": data['department']},
                  {"label": "Semester", "value": data['semester']},
                  {"label": "Parent Name", "value": data['parentName']},
                  {"label": "Parent Phone", "value": data['parentPhone']},
                  {"label": "Parent Email", "value": data['parentEmail']},
                  {"label": "KTU ID", "value": data['ktuid']},
                  {"label": "Date of Admission", "value": data['dateOfAdmission']},
                ]);
              }),

              _tile(context, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditProfilePage(
                      admissionNo: admissionNo,
                      data: data,
                    ),
                  ),
                );
              }),

              _tile(
                context,
                "Logout",
                () => _confirmLogout(context),
                color: Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    VoidCallback onTap, {
    Color color = Colors.black,
  }) {
    return Card(
      child: ListTile(
        title: Text(title, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
