import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/session.dart';
import '../screens/login_screen.dart';
import '../student/student_data.dart';
import 'parent_edit_profile_page.dart';

class ParentProfilePage extends StatelessWidget {
  ParentProfilePage({super.key});

  final parentId = Session.userId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parents')
            .doc(parentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final parent = snapshot.data!.data() as Map<String, dynamic>;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const CircleAvatar(
                radius: 40,
                child: Icon(Icons.person, size: 40),
              ),
              const SizedBox(height: 12),

              Center(
                child: Text(
                  parent['parentName'] ?? "Parent",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Center(child: Text(parent['parentPhone'])),

              const SizedBox(height: 24),

              _tile(context, "Personal Details", () {
                _showDetails(context, parent);
              }),

              _tile(context, "Edit Profile", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ParentEditProfilePage(
                      parentUserId: parentId!,
                      parentData: parent,
                    ),
                  ),
                );
              }),

              _tile(context, "Logout", () => _logout(context),
                  color: Colors.red),
            ],
          );
        },
      ),
    );
  }

  void _showDetails(BuildContext context, Map<String, dynamic> parent) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row("Parent Name", parent['parentName'] ?? "N/A"),
            _row("Phone", parent['parentPhone']),
            _row("Student", StudentData.name),
            _row("Admission No", StudentData.admissionNo),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(color: Colors.grey)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
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
            child:
                const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext c, String t, VoidCallback onTap,
      {Color color = Colors.black}) {
    return Card(
      child: ListTile(
        title: Text(t, style: TextStyle(color: color)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
