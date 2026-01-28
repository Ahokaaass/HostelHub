import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String admissionNo;
  final Map<String, dynamic> data;

  const EditProfilePage({
    super.key,
    required this.admissionNo,
    required this.data,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController email;
  late TextEditingController phone;
  late TextEditingController parentPhone;
  late TextEditingController parentEmail;
  late TextEditingController password;

  @override
  void initState() {
    super.initState();
    email = TextEditingController(text: widget.data['email']);
    phone = TextEditingController(text: widget.data['phone']);
    parentPhone = TextEditingController(text: widget.data['parentPhone']);
    parentEmail = TextEditingController(text: widget.data['parentEmail']);
    password = TextEditingController(text: widget.data['password']);
  }

  Future<void> _save() async {
    final newPhone = phone.text.trim();
    final newPassword = "student@${newPhone.substring(6)}";

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.admissionNo)
        .update({
      "email": email.text.trim(),
      "phone": newPhone,
      "parentPhone": parentPhone.text.trim(),
      "parentEmail": parentEmail.text.trim(),
      "password": newPassword,
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
          _tf("Email", email),
          _tf("Phone", phone, isPhone: true),
          _tf("Parent Phone", parentPhone, isPhone: true),
          _tf("Parent Email", parentEmail),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _save, child: const Text("Save Changes")),
        ],
      ),
    );
  }

  Widget _tf(String label, TextEditingController c,
      {bool isPhone = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType:
            isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
