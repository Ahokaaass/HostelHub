import 'package:flutter/material.dart';
import 'request_list_page.dart';
import 'complaint_list_page.dart';

class RequestComplaintPage extends StatelessWidget {
  const RequestComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Requests & Complaints"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _option(
            context,
            title: "View Requests",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RequestListPage(),
                ),
              );
            },
          ),
          _option(
            context,
            title: "View Complaints",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ComplaintListPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _option(
    BuildContext context, {
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
