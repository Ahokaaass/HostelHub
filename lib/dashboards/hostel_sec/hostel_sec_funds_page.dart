import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HostelSecFundsPage extends StatelessWidget {
  const HostelSecFundsPage({super.key});

  /// Open PDF
  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hostel Fund Reports")),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostel_funds')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No reports available"));
          }

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              final label = data['label'] ?? "Report";
              final fileName = data['fileName'] ?? "";
              final url = data['url'] ?? "";

              final ts = data['uploadedAt'] as Timestamp?;
              final date = ts != null
                  ? DateFormat('dd MMM yyyy').format(ts.toDate())
                  : "";

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

                child: ListTile(
                  leading: const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.red,
                    size: 32,
                  ),

                  title: Text(label),

                  subtitle: Text("$fileName • $date"),

                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: () => _openPdf(url),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
