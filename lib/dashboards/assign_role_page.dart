import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignRolePage extends StatefulWidget {
  const AssignRolePage({super.key});

  @override
  State<AssignRolePage> createState() => _AssignRolePageState();
}

class _AssignRolePageState extends State<AssignRolePage> {
  final TextEditingController admissionController = TextEditingController();

  Map<String, dynamic>? selectedStudent;
  String selectedRole = "Hostel Secretary";

  // ================= SEARCH STUDENT =================
  Future<void> _searchStudent() async {
    final admNo = admissionController.text.trim();

    if (admNo.isEmpty) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(admNo)
        .get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student not found")),
      );
      setState(() => selectedStudent = null);
      return;
    }

    setState(() {
      selectedStudent = doc.data();
    });
  }

  // ================= ASSIGN ROLE =================
  Future<void> _assignRole() async {
    if (selectedStudent == null) return;

    final admissionNo = selectedStudent!['admissionNo'];

    final updateData = selectedRole == "Wing Secretary"
        ? {"isWingSecretary": true}
        : {"isHostelSecretary": true};

    await FirebaseFirestore.instance
        .collection('users')
        .doc(admissionNo)
        .update(updateData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$selectedRole assigned successfully")),
    );

    setState(() {
      selectedStudent = null;
      admissionController.clear();
    });
  }

  // ================= REMOVE ROLE =================
  Future<void> _removeRole(
    String admissionNo,
    String role,
  ) async {
    final updateData = role == "Wing Secretary"
        ? {"isWingSecretary": false}
        : {"isHostelSecretary": false};

    await FirebaseFirestore.instance
        .collection('users')
        .doc(admissionNo)
        .update(updateData);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$role removed successfully")),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Assign Roles")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== ASSIGN ==========
            const Text(
              "Assign New Role",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: admissionController,
              decoration: const InputDecoration(
                labelText: "Admission Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedRole,
              items: const [
                DropdownMenuItem(
                  value: "Hostel Secretary",
                  child: Text("Hostel Secretary"),
                ),
                DropdownMenuItem(
                  value: "Wing Secretary",
                  child: Text("Wing Secretary"),
                ),
              ],
              onChanged: (v) => setState(() => selectedRole = v!),
              decoration: const InputDecoration(
                labelText: "Select Role",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _searchStudent,
              child: const Text("Search Student"),
            ),

            if (selectedStudent != null) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: Text(selectedStudent!['name']),
                  subtitle: Text(
                    "Adm: ${selectedStudent!['admissionNo']}\n"
                    "Dept: ${selectedStudent!['department']}\n"
                    "Semester: ${selectedStudent!['semester']}",
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _assignRole,
                child: const Text("Assign Role"),
              ),
            ],

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),

            // ========== VIEW ==========
            const Text(
              "Current Role Holders",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _roleSection("Hostel Secretary", "isHostelSecretary"),
            const SizedBox(height: 12),
            _roleSection("Wing Secretary", "isWingSecretary"),
          ],
        ),
      ),
    );
  }

  // ================= ROLE VIEW =================
  Widget _roleSection(String title, String field) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where(field, isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return ExpansionTile(
            title: Text(title),
            children: const [
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("No one assigned"),
              ),
            ],
          );
        }

        return ExpansionTile(
          title: Text(title),
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              title: Text(data['name']),
              subtitle:
                  Text("Admission No: ${data['admissionNo']}"),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeRole(
                  data['admissionNo'],
                  title,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
