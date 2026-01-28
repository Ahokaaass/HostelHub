import 'package:flutter/material.dart';

class HostelSecRequestsPage extends StatelessWidget {
  const HostelSecRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      {
        "name": "Sherin Ibadhi K",
        "room": "1313",
        "status": "Submitted",
      },
      {
        "name": "Anjali P",
        "room": "1204",
        "status": "Approved",
      },
      {
        "name": "Rahul M",
        "room": "1109",
        "status": "Pending",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Outgoing Requests")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final r = requests[index];
          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF3A6B52),
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text("${r['name']} (Room ${r['room']})"),
              subtitle: Text("Status: ${r['status']}"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
