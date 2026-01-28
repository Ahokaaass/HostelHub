import 'package:flutter/material.dart';

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  State<ComplaintListPage> createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  List<Map<String, String>> complaints = [
    {
      "student": "Rahul",
      "room": "301",
      "issue": "Fan not working",
    },
    {
      "student": "Anjali",
      "room": "108",
      "issue": "Water leakage",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaints")),
      body: complaints.isEmpty
          ? const Center(child: Text("No complaints"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final c = complaints[index];
                return Card(
                  child: ListTile(
                    title: Text("${c["student"]} • Room ${c["room"]}"),
                    subtitle: Text(c["issue"]!),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "approve") {
                          _confirmApprove(index);
                        } else {
                          _confirmReject(index);
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: "approve",
                          child: Text("Forward"),
                        ),
                        PopupMenuItem(
                          value: "reject",
                          child: Text("Reject"),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmApprove(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm"),
        content: const Text("Forward this complaint?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => complaints.removeAt(index));
              Navigator.pop(context);
              _showSuccess("Complaint forwarded");
            },
            child: const Text("Forward"),
          ),
        ],
      ),
    );
  }

  void _confirmReject(int index) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reject Complaint"),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            hintText: "Enter rejection reason",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => complaints.removeAt(index));
              Navigator.pop(context);
              _showSuccess("Complaint rejected");
            },
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
