import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StaffEditProfilePage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> data;

  const StaffEditProfilePage({
    super.key,
    required this.userId,
    required this.data,
  });

  @override
  State<StaffEditProfilePage> createState() =>
      _StaffEditProfilePageState();
}

class _StaffEditProfilePageState extends State<StaffEditProfilePage> {
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController staffId;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.data['name']);
    email = TextEditingController(text: widget.data['email']);
    phone = TextEditingController(text: widget.data['phone']);
    staffId = TextEditingController(text: widget.data['staffId']);
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.userId)
        .update({
      "name": name.text.trim(),
      "email": email.text.trim(),
      "phone": phone.text.trim(),
      "staffId": staffId.text.trim(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tf("Name", name),
          _tf("Email", email),
          _tf("Phone", phone),
          _tf("Staff ID", staffId),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text("Save")),
        ],
      ),
    );
  }

  Widget _tf(String l, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration:
            InputDecoration(labelText: l, border: const OutlineInputBorder()),
      ),
    );
  }
}
