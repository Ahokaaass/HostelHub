import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);
const _kRed       = Color(0xFFB71C1C);
const _kRedBg     = Color(0xFFFFEBEE);
const _kGreen     = Color(0xFF2E7D32);

class HostelFundsPage extends StatefulWidget {
  const HostelFundsPage({super.key});

  @override
  State<HostelFundsPage> createState() => _HostelFundsPageState();
}

class _HostelFundsPageState extends State<HostelFundsPage> {
  bool   _uploading      = false;
  double _uploadProgress = 0;
  String _uploadingLabel = '';

  // ── Upload PDF ─────────────────────────────────────────────────────────────
  Future<void> _uploadPdf() async {
    // On mobile: withData=false → use file path with putFile() (reliable)
    // On web:    withData=true  → use bytes with putData() (only option)
    final result = await FilePicker.platform.pickFiles(
      type             : FileType.custom,
      allowedExtensions: ['pdf'],
      withData         : kIsWeb,
    );
    if (result == null || result.files.isEmpty) return;

    final picked   = result.files.single;
    final fileName = picked.name;

    // Guard checks
    if (!kIsWeb && (picked.path == null || picked.path!.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content        : Text('Could not get file path. Please try again.'),
        backgroundColor: Colors.red,
        behavior       : SnackBarBehavior.floating,
      ));
      return;
    }
    if (kIsWeb && (picked.bytes == null || picked.bytes!.isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content        : Text('Could not read file bytes. Please try again.'),
        backgroundColor: Colors.red,
        behavior       : SnackBarBehavior.floating,
      ));
      return;
    }

    // Step 2: Ask for label
    final labelCtrl = TextEditingController(
        text: fileName.replaceAll(
            RegExp(r'\.pdf$', caseSensitive: false), ''));
    final label = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape           : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Report Label',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children    : [
            const Text(
              'Give this report a descriptive name:',
              style: TextStyle(color: _kSubtext, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: labelCtrl,
              autofocus : true,
              decoration: InputDecoration(
                hintText      : 'e.g. March 2025 Fund Report',
                hintStyle     : const TextStyle(
                    color: _kSubtext, fontSize: 13),
                filled        : true,
                fillColor     : _kBlueTint,
                border        : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide  : BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child    : const Text('Cancel',
                style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton.icon(
            onPressed: () =>
                Navigator.pop(context, labelCtrl.text.trim()),
            icon : const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Upload'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlue,
              foregroundColor: Colors.white,
              elevation      : 0,
              shape          : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );

    if (label == null || label.isEmpty) return;

    // Step 3: Upload
    setState(() {
      _uploading      = true;
      _uploadProgress = 0;
      _uploadingLabel = label;
    });

    try {
      final storagePath =
          'hostel_funds/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      final metadata = SettableMetadata(contentType: 'application/pdf');

      // ✅ putFile on mobile (works reliably), putData on web (only option)
      final UploadTask uploadTask = kIsWeb
          ? ref.putData(picked.bytes!, metadata)
          : ref.putFile(File(picked.path!), metadata);

      // Progress listener
      uploadTask.snapshotEvents.listen((TaskSnapshot snap) {
        if (!mounted) return;
        if (snap.totalBytes > 0) {
          setState(() =>
              _uploadProgress = snap.bytesTransferred / snap.totalBytes);
        }
      });

      // Wait for completion
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state != TaskState.success) {
        throw Exception('Upload did not complete successfully.');
      }

      // Get URL only after confirmed success
      final String url = await snapshot.ref.getDownloadURL();

      // File size
      final int sizeKb = kIsWeb
          ? (picked.bytes!.length ~/ 1024)
          : (await File(picked.path!).length() ~/ 1024);

      // Save to Firestore
      await FirebaseFirestore.instance.collection('hostel_funds').add({
        'label'      : label,
        'fileName'   : fileName,
        'url'        : url,
        'storagePath': storagePath,
        'uploadedAt' : Timestamp.now(),
        'sizeKb'     : sizeKb,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : const Text('PDF uploaded successfully ✓'),
        backgroundColor: _kGreen,
        behavior       : SnackBarBehavior.floating,
        shape          : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration       : const Duration(seconds: 3),
      ));
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : Text('Firebase error: ${e.message ?? e.code}'),
        backgroundColor: _kRed,
        behavior       : SnackBarBehavior.floating,
        duration       : const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : Text('Upload failed: $e'),
        backgroundColor: _kRed,
        behavior       : SnackBarBehavior.floating,
        duration       : const Duration(seconds: 5),
      ));
    } finally {
      if (mounted) {
        setState(() {
          _uploading      = false;
          _uploadProgress = 0;
          _uploadingLabel = '';
        });
      }
    }
  }

  // ── Delete ─────────────────────────────────────────────────────────────────
  Future<void> _delete(
      String docId, String storagePath, String label) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor : Colors.white,
            surfaceTintColor: Colors.white,
            shape           : RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text('Delete Report',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize  : 17,
                    color     : _kText)),
            content: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: _kSubtext, fontSize: 14),
                children: [
                  const TextSpan(text: 'Permanently delete '),
                  TextSpan(
                      text : '"$label"',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color     : _kText)),
                  const TextSpan(text: '? This cannot be undone.'),
                ],
              ),
            ),
            actionsPadding:
                const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child    : const Text('Cancel',
                    style: TextStyle(color: _kSubtext)),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                icon : const Icon(
                    Icons.delete_outline_rounded, size: 16),
                label: const Text('Delete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kRed,
                  foregroundColor: Colors.white,
                  elevation      : 0,
                  shape          : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    try {
      await FirebaseStorage.instance.ref(storagePath).delete();
      await FirebaseFirestore.instance
          .collection('hostel_funds')
          .doc(docId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content        : const Text('Report deleted'),
        backgroundColor: _kRed,
        behavior       : SnackBarBehavior.floating,
        shape          : RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // ── Open PDF ───────────────────────────────────────────────────────────────
  Future<void> _openPdf(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open PDF')),
      );
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body           : Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            width     : double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                    color     : Color(0x351565C0),
                    blurRadius: 18,
                    offset    : Offset(0, 6)),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child : Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child  : Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color       : Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border      : Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hostel Funds',
                              style: TextStyle(
                                  color        : Colors.white,
                                  fontSize     : 20,
                                  fontWeight   : FontWeight.w800,
                                  letterSpacing: -0.3)),
                          SizedBox(height: 2),
                          Text('Upload and manage fund reports',
                              style: TextStyle(
                                  color  : Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _uploading ? null : _uploadPdf,
                      child: AnimatedOpacity(
                        opacity : _uploading ? 0.5 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child   : Container(
                          padding   : const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 9),
                          decoration: BoxDecoration(
                            color       : Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(11),
                            border      : Border.all(
                                color: Colors.white.withOpacity(0.35)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children    : [
                              Icon(Icons.upload_file_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text('Upload PDF',
                                  style: TextStyle(
                                      color     : Colors.white,
                                      fontSize  : 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Upload progress bar ──────────────────────────────────────
          if (_uploading)
            Container(
              margin : const EdgeInsets.fromLTRB(20, 16, 20, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color       : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border      : Border.all(color: _kBorder),
                boxShadow   : const [
                  BoxShadow(
                      color     : Color(0x0A1565C0),
                      blurRadius: 8,
                      offset    : Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children          : [
                  Row(
                    children: [
                      const SizedBox(
                        width : 16,
                        height: 16,
                        child : CircularProgressIndicator(
                            strokeWidth: 2, color: _kBlue),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Uploading "$_uploadingLabel"…',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 13,
                              color     : _kBlue),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            fontSize  : 12,
                            fontWeight: FontWeight.w700,
                            color     : _kBlue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child       : LinearProgressIndicator(
                      value          : _uploadProgress,
                      minHeight      : 6,
                      backgroundColor: _kBlueTint,
                      valueColor     :
                          const AlwaysStoppedAnimation(_kBlue),
                    ),
                  ),
                ],
              ),
            ),

          // ── PDF list ────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream : FirebaseFirestore.instance
                  .collection('hostel_funds')
                  .orderBy('uploadedAt', descending: true)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !_uploading) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }

                final docs = snap.data?.docs ?? [];

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children    : [
                        Container(
                          width     : 72,
                          height    : 72,
                          decoration: BoxDecoration(
                              color       : _kBlueTint,
                              borderRadius: BorderRadius.circular(22)),
                          child: const Icon(Icons.folder_open_rounded,
                              color: _kBlue, size: 34),
                        ),
                        const SizedBox(height: 16),
                        const Text('No reports uploaded yet',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize  : 15,
                                color     : _kText)),
                        const SizedBox(height: 6),
                        const Text(
                          'Tap "Upload PDF" in the header to add a report',
                          style    : TextStyle(
                              color: _kSubtext, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _uploadPdf,
                          icon : const Icon(
                              Icons.upload_file_rounded, size: 18),
                          label: const Text('Upload First Report'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _kBlue,
                            foregroundColor: Colors.white,
                            elevation      : 0,
                            shape          : RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 22, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding    : const EdgeInsets.fromLTRB(20, 20, 20, 36),
                  itemCount  : docs.length,
                  itemBuilder: (_, i) {
                    final doc  = docs[i];
                    final data = doc.data() as Map<String, dynamic>;

                    final label       = data['label']       ?? 'Report';
                    final fileName    = data['fileName']    ?? '';
                    final url         = data['url']         ?? '';
                    final storagePath = data['storagePath'] ?? '';
                    final sizeKb      = data['sizeKb']      ?? 0;
                    final ts = data['uploadedAt'] as Timestamp?;
                    final dateStr = ts != null
                        ? DateFormat('dd MMM yyyy · hh:mm a')
                            .format(ts.toDate())
                        : 'Unknown date';

                    return Container(
                      margin    : const EdgeInsets.only(bottom: 12),
                      padding   : const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color       : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border      : Border.all(
                            color: _kBorder, width: 1.2),
                        boxShadow   : const [
                          BoxShadow(
                              color     : Color(0x0F1565C0),
                              blurRadius: 10,
                              offset    : Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width     : 50,
                            height    : 50,
                            decoration: BoxDecoration(
                              color       : _kRedBg,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: _kRed,
                                size : 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(label,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize  : 14,
                                        color     : _kText)),
                                const SizedBox(height: 3),
                                Text(
                                  fileName,
                                  maxLines : 1,
                                  overflow : TextOverflow.ellipsis,
                                  style    : const TextStyle(
                                      fontSize: 11,
                                      color   : _kSubtext),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                        Icons.access_time_rounded,
                                        size : 11,
                                        color: _kSubtext),
                                    const SizedBox(width: 3),
                                    Expanded(
                                      child: Text(
                                        '$dateStr${sizeKb > 0 ? " · ${sizeKb}KB" : ""}',
                                        style   : const TextStyle(
                                            fontSize: 11,
                                            color   : _kSubtext),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            children: [
                              _ActionBtn(
                                icon   : Icons.open_in_new_rounded,
                                color  : _kBlue,
                                bg     : _kBlueTint,
                                tooltip: 'View PDF',
                                onTap  : () => _openPdf(url),
                              ),
                              const SizedBox(height: 8),
                              _ActionBtn(
                                icon   : Icons.delete_outline_rounded,
                                color  : _kRed,
                                bg     : _kRedBg,
                                tooltip: 'Delete',
                                onTap  : () => _delete(
                                    doc.id, storagePath, label),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final Color        color;
  final Color        bg;
  final String       tooltip;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.color,
    required this.bg,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child   : GestureDetector(
        onTap: onTap,
        child: Container(
          width     : 36,
          height    : 36,
          decoration: BoxDecoration(
              color       : bg,
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}