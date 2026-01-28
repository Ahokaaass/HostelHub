import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ParentEditProfilePage extends StatefulWidget {
  final String parentUserId;
  final Map<String, dynamic> parentData;

  const ParentEditProfilePage({
    super.key,
    required this.parentUserId,
    required this.parentData,
  });

  @override
  State<ParentEditProfilePage> createState() =>
      _ParentEditProfilePageState();
}

class _ParentEditProfilePageState extends State<ParentEditProfilePage> {
  late TextEditingController name;
  late TextEditingController phone;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.parentData['parentName']);
    phone =
        TextEditingController(text: widget.parentData['parentPhone']);
  }

  Future<void> _save() async {
    await FirebaseFirestore.instance
        .collection('parents')
        .doc(widget.parentUserId)
        .update({
      'parentName': name.text.trim(),
      'parentPhone': phone.text.trim(),
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
          _tf("Phone", phone),
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
