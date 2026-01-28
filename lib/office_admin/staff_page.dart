import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffPage extends StatelessWidget {
  const StaffPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Staff Management")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _option(
              context,
              "Add Matron",
              Icons.female,
              const AddStaffPage(role: "matron"),
            ),
            _option(
              context,
              "Add RT",
              Icons.security,
              const AddStaffPage(role: "rt"),
            ),
            _option(
              context,
              "Add Warden",
              Icons.admin_panel_settings,
              const AddStaffPage(role: "warden"),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const Expanded(child: _StaffList()),
          ],
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

/// ===============================
/// ADD STAFF PAGE
/// ===============================
class AddStaffPage extends StatefulWidget {
  final String role;
  const AddStaffPage({super.key, required this.role});

  @override
  State<AddStaffPage> createState() => _AddStaffPageState();
}

class _AddStaffPageState extends State<AddStaffPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final staffId = TextEditingController();

  String? hostel;

  @override
  Widget build(BuildContext context) {
    final needsHostel = widget.role != "warden";

    return Scaffold(
      appBar: AppBar(title: Text("Add ${widget.role.toUpperCase()}")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: hostel,
              decoration: const InputDecoration(
                labelText: "Hostel",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "nila", child: Text("Nila")),
                DropdownMenuItem(value: "kabani", child: Text("Kabani")),
              ],
              onChanged: needsHostel
                  ? (v) => setState(() => hostel = v)
                  : null,
            ),
            const SizedBox(height: 12),
            _tf("Name", name),
            _tf("Staff ID", staffId),
            _tf("Phone", phone, type: TextInputType.phone),
            _tf("Email", email, type: TextInputType.emailAddress),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text("Add Staff"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (name.text.isEmpty ||
        phone.text.length < 10 ||
        staffId.text.isEmpty ||
        email.text.isEmpty ||
        (widget.role != "warden" && hostel == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields correctly")),
      );
      return;
    }

    final last4 = phone.text.substring(phone.text.length - 4);
    final userId =
        widget.role == "warden" ? "warden" : "${widget.role}@${hostel!}";
    final password = "${widget.role}@$last4";

    await FirebaseFirestore.instance.collection('staff').doc(userId).set({
      "name": name.text,
      "phone": phone.text,
      "email": email.text,
      "staffId": staffId.text,
      "role": widget.role,
      "hostel": hostel,
      "userId": userId,
      "password": password,
      "createdAt": Timestamp.now(),
    });

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: Text(
          "Staff added successfully\n\nUser ID: $userId\nPassword: $password",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _tf(
    String label,
    TextEditingController c, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// ===============================
/// STAFF LIST (SAFE & FIXED)
/// ===============================
class _StaffList extends StatelessWidget {
  const _StaffList();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('staff').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No staff added"));
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            final name = data['name'] ?? 'No Name';
            final role = data['role'] ?? 'unknown';
            final hostel = data['hostel'];
            final userId = data['userId'] ?? doc.id; // ✅ SAFE FALLBACK

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),
                title: Text(name),
                subtitle: Text(
                  "Role: ${role.toUpperCase()}\n"
                  "Hostel: ${hostel ?? "Common"}\n"
                  "User ID: $userId",
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
