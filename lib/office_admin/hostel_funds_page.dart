import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Colors ─────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBg = Color(0xFFF5F8FF);
const _kRed = Color(0xFFB71C1C);
const _kGreen = Color(0xFF2E7D32);

class HostelFundsPage extends StatefulWidget {
  const HostelFundsPage({super.key});

  @override
  State<HostelFundsPage> createState() => _HostelFundsPageState();
}

class _HostelFundsPageState extends State<HostelFundsPage> {
  /// CLOUDINARY UPLOAD FUNCTION
  Future<String?> uploadPdfToCloudinary(
    Uint8List fileBytes,
    String fileName,
  ) async {
    const cloudName = "dj0ykuyyv";
    const uploadPreset = "hostel_pdf_upload";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/raw/upload",
    );

    var request = http.MultipartRequest("POST", url);

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await http.Response.fromStream(response);
      var data = jsonDecode(responseData.body);
      return data['secure_url'];
    }

    return null;
  }

  /// PICK + UPLOAD PDF
  Future<void> _uploadPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result == null) return;

    final file = result.files.first;
    Uint8List? fileBytes = file.bytes;
    final fileName = file.name.replaceAll('.pdf', '');

    if (fileBytes == null) {
      if (!kIsWeb && file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to read selected file")),
        );
        return;
      }
    }

    final labelCtrl = TextEditingController(
      text: fileName.replaceAll('.pdf', ''),
    );

    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Report Label'),
        content: TextField(
          controller: labelCtrl,
          decoration: const InputDecoration(
            hintText: 'Ex: March 2026 Fund Report',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, labelCtrl.text.trim()),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;

    try {
      final url = await uploadPdfToCloudinary(fileBytes, fileName);

      if (url == null) {
        throw Exception('Upload failed');
      }

      await FirebaseFirestore.instance.collection('hostel_funds').add({
        'label': label,
        'fileName': fileName,
        'url': url,
        'uploadedAt': Timestamp.now(),
        'sizeKb': fileBytes.length ~/ 1024,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF uploaded successfully'),
          backgroundColor: _kGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e'), backgroundColor: _kRed),
      );
    }
  }

  /// OPEN PDF — uses Google Docs Viewer so it works on ALL devices
  /// (phones without a PDF app, laptops, iPhones, Android — everything)
  Future<void> _openPdf(String url) async {
    final googleViewerUrl = Uri.parse(
      'https://docs.google.com/viewer?url=${Uri.encodeComponent(url)}',
    );

    if (await canLaunchUrl(googleViewerUrl)) {
      await launchUrl(
        googleViewerUrl,
        mode: LaunchMode.externalApplication, // opens in phone browser
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open PDF. Please try again.'),
          backgroundColor: _kRed,
        ),
      );
    }
  }

  /// DELETE REPORT
  Future<void> _delete(String docId) async {
    // Show confirmation dialog before deleting
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: _kRed),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await FirebaseFirestore.instance
        .collection('hostel_funds')
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report deleted'), backgroundColor: _kRed),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      appBar: AppBar(
        title: const Text("Hostel Funds"),
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Upload PDF Report',
            onPressed: _uploadPdf,
          ),
        ],
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
                    "No reports uploaded yet",
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

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // View button
                      IconButton(
                        icon: const Icon(Icons.open_in_new, color: _kBlue),
                        tooltip: 'View PDF',
                        onPressed: url.isNotEmpty ? () => _openPdf(url) : null,
                      ),

                      // Delete button
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: _kRed),
                        tooltip: 'Delete Report',
                        onPressed: () => _delete(doc.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // FAB as alternate upload button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadPdf,
        backgroundColor: _kBlue,
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text(
          'Upload Report',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
