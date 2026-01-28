import 'package:flutter/material.dart';
import 'hostel_sec_complaint_detail_page.dart';

class HostelSecComplaintsPage extends StatelessWidget {
  const HostelSecComplaintsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final complaints = [
      {
        "category": "Room Complaint",
        "room": "1313",
        "message": "Fan not working",
        "status": "Submitted",
      },
      {
        "category": "Mess Complaint",
        "room": "1204",
        "message": "Food quality is poor",
        "status": "Submitted",
      },
      {
        "category": "General Complaint",
        "room": "1109",
        "message": "Water issue in bathroom",
        "status": "Submitted",
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("All Complaints")),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: complaints.length,
        itemBuilder: (context, index) {
          final c = complaints[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.error, color: Colors.green),
              title: Text("${c['category']} (Room ${c['room']})"),
              subtitle: Text("Status: ${c['status']}"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        HostelSecComplaintDetailPage(data: c),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
