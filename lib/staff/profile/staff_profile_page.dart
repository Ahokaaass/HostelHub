import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'staff_detail_sheet.dart';
import 'staff_edit_profile.dart';
import '../../screens/login_screen.dart';

class StaffProfilePage extends StatelessWidget {
  final String userId;

  const StaffProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('staff')
            .doc(userId)
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
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(child: Text(data['email'])),

              const SizedBox(height: 24),

              _tile(context, "Personal Details", () {
                showStaffDetailSheet(context, [
                  {"label": "Staff ID", "value": data['staffId']},
                  {"label": "Phone", "value": data['phone']},
                  {"label": "Hostel", "value": data['hostel']},
                  {"label": "Role", "value": data['role']},
                  {"label": "User ID", "value": data['userId']},
                ]);
              }),

              _tile(context, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StaffEditProfilePage(
                      userId: userId,
                      data: data,
                    ),
                  ),
                );
              }),

              _tile(
                context,
                "Logout",
                () => _logout(context),
                color: Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }

  void _logout(BuildContext context) {
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
            child: const Text("Logout",
                style: TextStyle(color: Colors.red)),
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
