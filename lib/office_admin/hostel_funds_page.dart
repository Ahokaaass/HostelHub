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
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint = Color(0xFFE8F0FE);
const _kBorder = Color(0xFFBBD0F8);
const _kBg = Color(0xFFF5F8FF);
const _kText = Color(0xFF1A1A2E);
const _kSubtext = Color(0xFF6B7280);
const _kRed = Color(0xFFB71C1C);
const _kRedBg = Color(0xFFFFEBEE);
const _kGreen = Color(0xFF2E7D32);

class HostelFundsPage extends StatefulWidget {
  const HostelFundsPage({super.key});

  @override
  State<HostelFundsPage> createState() => _HostelFundsPageState();
}

class _HostelFundsPageState extends State<HostelFundsPage> {
  bool _uploading = false;
  double _uploadProgress = 0;
  String _uploadingLabel = '';

  /// CLOUDINARY UPLOAD FUNCTION
  Future<String?> uploadPdfToCloudinary(
    Uint8List fileBytes,
    String fileName,
  ) async {
    const cloudName = "dj0ykuyyv";
    const uploadPreset = "hostel_pdf_upload";

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/dj0ykuyyv/raw/upload",
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
    } else {
      return null;
    }
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

    Uint8List fileBytes = file.bytes!;
    String fileName = file.name;

    /// Ask report label
    final labelCtrl = TextEditingController(
      text: fileName.replaceAll(".pdf", ""),
    );

    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Report Label"),
        content: TextField(
          controller: labelCtrl,
          decoration: const InputDecoration(
            hintText: "Ex: March 2026 Fund Report",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, labelCtrl.text.trim()),
            child: const Text("Upload"),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;

    setState(() {
      _uploading = true;
      _uploadingLabel = label;
    });

    try {
      /// Upload to Cloudinary
      final url = await uploadPdfToCloudinary(fileBytes, fileName);

      if (url == null) {
        throw Exception("Upload failed");
      }

      /// Save to Firestore
      await FirebaseFirestore.instance.collection('hostel_funds').add({
        'label': label,
        'fileName': fileName,
        'url': url,
        'uploadedAt': Timestamp.now(),
        'sizeKb': fileBytes.length ~/ 1024,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("PDF uploaded successfully"),
          backgroundColor: _kGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e"), backgroundColor: _kRed),
      );
    }

    setState(() {
      _uploading = false;
      _uploadingLabel = '';
      _uploadProgress = 0;
    });
  }

  /// OPEN PDF
  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// DELETE REPORT
  Future<void> _delete(String docId) async {
    await FirebaseFirestore.instance
        .collection('hostel_funds')
        .doc(docId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,

      appBar: AppBar(
        title: const Text("Hostel Funds"),
        backgroundColor: _kBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
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
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No reports uploaded yet"));
          }

          return ListView.builder(
            itemCount: docs.length,

            itemBuilder: (_, i) {
              final doc = docs[i];

              final data = doc.data() as Map<String, dynamic>;

              final label = data['label'];
              final fileName = data['fileName'];
              final url = data['url'];

              final ts = data['uploadedAt'] as Timestamp?;

              final dateStr = ts != null
                  ? DateFormat('dd MMM yyyy').format(ts.toDate())
                  : "";

              return ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: _kRed),

                title: Text(label),

                subtitle: Text("$fileName • $dateStr"),

                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () => _openPdf(url),
                    ),

                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _delete(doc.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
