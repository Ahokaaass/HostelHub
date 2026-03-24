import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class HostelSecFundsPage extends StatelessWidget {
  const HostelSecFundsPage({super.key});

  /// Open PDF in viewer
  Future<void> _viewPdf(String url) async {
    final viewer = "https://docs.google.com/gview?embedded=true&url=$url";

    final uri = Uri.parse(viewer);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Direct download
  Future<void> _downloadPdf(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Show options (view / download)
  void _showOptions(BuildContext context, String url) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text("Open PDF"),
                onTap: () {
                  Navigator.pop(context);
                  _viewPdf(url);
                },
              ),

              ListTile(
                leading: const Icon(Icons.download),
                title: const Text("Download PDF"),
                onTap: () {
                  Navigator.pop(context);
                  _downloadPdf(url);
                },
              ),
            ],
          ),
        );
      },
    );
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
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, url),
                  ),

                  onTap: () => _viewPdf(url),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
