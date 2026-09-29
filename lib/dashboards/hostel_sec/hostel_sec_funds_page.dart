import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Colors ─────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBg = Color(0xFFF5F8FF);
const _kRed = Color(0xFFB71C1C);

class HostelSecFundsPage extends StatelessWidget {
  const HostelSecFundsPage({super.key});

  /// OPEN PDF — uses Google Docs Viewer so it works on ALL devices
  Future<void> _openPdf(String url) async {
    final googleViewerUrl = Uri.parse(
      'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}',
    );

    if (await canLaunchUrl(googleViewerUrl)) {
      await launchUrl(googleViewerUrl, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not open PDF');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      appBar: AppBar(
        title: const Text("Hostel Fund Reports"),
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hostel_funds')
            .orderBy('uploadedAt', descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Something went wrong.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No reports available",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),

            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final label = data['label'] ?? 'Untitled';
              final fileName = data['fileName'] ?? '';
              final url = data['url'] ?? '';
              final sizeKb = data['sizeKb'];

              final ts = data['uploadedAt'] as Timestamp?;
              final dateStr = ts != null
                  ? DateFormat('dd MMM yyyy').format(ts.toDate())
                  : '';

              final subtitle = [
                if (fileName.isNotEmpty) fileName,
                if (dateStr.isNotEmpty) dateStr,
                if (sizeKb != null) '$sizeKb KB',
              ].join(' • ');

              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFEBEE),
                    child: Icon(Icons.picture_as_pdf, color: _kRed),
                  ),

                  title: Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  subtitle: Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),

                  trailing: IconButton(
                    icon: const Icon(Icons.open_in_new, color: _kBlue),
                    tooltip: 'View PDF',
                    onPressed: url.isNotEmpty ? () => _openPdf(url) : null,
                  ),

                  onTap: url.isNotEmpty ? () => _openPdf(url) : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
