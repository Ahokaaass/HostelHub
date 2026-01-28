import 'package:flutter/material.dart';

class HostelSecComplaintDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;

  const HostelSecComplaintDetailPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaint Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${data['category']}"),
            const SizedBox(height: 6),
            Text("Room: ${data['room']}"),
            const SizedBox(height: 16),

            const Text(
              "Message",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(data['message']),

            const SizedBox(height: 24),

            const Text(
              "Status Tracker",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _step("Submitted", true),
            _step("Hostel Secretary", false),
            _step("Matron", false),
            _step("RT", false),
            _step("Warden", false),
            _step("Office Admin", false),
          ],
        ),
      ),
    );
  }

  Widget _step(String title, bool done) {
    return Row(
      children: [
        Icon(
          done ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: done ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 8),
        Text(title),
      ],
    );
  }
}
