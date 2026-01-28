import 'package:flutter/material.dart';

class RequestListPage extends StatefulWidget {
  const RequestListPage({super.key});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  // dummy data for now
  List<Map<String, String>> requests = [
    {
      "student": "Akhil",
      "room": "203",
      "reason": "Late entry after 9:30 PM",
    },
    {
      "student": "Sneha",
      "room": "115",
      "reason": "Early exit for exam",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Requests")),
      body: requests.isEmpty
          ? const Center(child: Text("No pending requests"))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final r = requests[index];
                return Card(
                  child: ListTile(
                    title: Text("${r["student"]} • Room ${r["room"]}"),
                    subtitle: Text(r["reason"]!),
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
                          child: Text("Approve"),
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
        content: const Text("Approve this request?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => requests.removeAt(index));
              Navigator.pop(context);
              _showSuccess("Request approved");
            },
            child: const Text("Approve"),
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
        title: const Text("Reject Request"),
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
              setState(() => requests.removeAt(index));
              Navigator.pop(context);
              _showSuccess("Request rejected");
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
