import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue       = Color(0xFF1565C0);
const _kBlueLight  = Color(0xFF1E88E5);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg         = Color(0xFFF5F8FF);
const _kDark       = Color(0xFF1A1A2E);
const _kGrey       = Color(0xFF6B7280);

class StudentRecordsPage extends StatefulWidget {
  const StudentRecordsPage({super.key});

  @override
  State<StudentRecordsPage> createState() => _StudentRecordsPageState();
}

class _StudentRecordsPageState extends State<StudentRecordsPage> {
  bool _uploading = false;
  String _search  = '';

  // ── CSV Upload ────────────────────────────────────────────────────────────
  Future<void> _uploadCSV() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (result == null) return;

      setState(() => _uploading = true);

      final file      = File(result.files.single.path!);
      final csvString = await file.readAsString();
      final rows      = const CsvToListConverter().convert(csvString);

      int count = 0;
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 11) continue;

        final admissionNo = row[1].toString().trim();
        final phone       = row[3].toString().trim();
        if (admissionNo.isEmpty || phone.length < 4) continue;

        final last4    = phone.substring(phone.length - 4);
        final password = 'student@$last4';

        await FirebaseFirestore.instance
            .collection('users')
            .doc(admissionNo)
            .set({
          'name'           : row[0].toString(),
          'admissionNo'    : admissionNo,
          'email'          : row[2].toString(),
          'phone'          : phone,
          'department'     : row[4].toString(),
          'semester'       : row[5].toString(),
          'parentName'     : row[6].toString(),
          'parentPhone'    : row[7].toString(),
          'parentEmail'    : row[8].toString(),
          'ktuid'          : row[9].toString(),
          'dateOfAdmission': row[10].toString(),
          'userId'         : admissionNo,
          'password'       : password,
          'isFirstLogin'   : true,
          'role'           : 'student',
          'isHostelSecretary': false,
          'isWingSecretary'  : false,
        });
        count++;
      }

      if (mounted) {
        setState(() => _uploading = false);
        _showSnack('$count students uploaded successfully!',
            Colors.green.shade600);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        _showSnack('Error: $e', Colors.red.shade600);
      }
    }
  }

  // ── Delete student ────────────────────────────────────────────────────────
  Future<void> _deleteStudent(
      BuildContext context, String docId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Student',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: _kGrey, fontSize: 14, height: 1.5),
            children: [
              const TextSpan(text: 'Are you sure you want to delete '),
              TextSpan(
                text: name,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _kDark),
              ),
              const TextSpan(
                  text: '? This action cannot be undone.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .delete();
      if (mounted) _showSnack('$name deleted.', Colors.red.shade600);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: _kBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0D47A1), _kBlueLight],
                      ),
                    ),
                  ),
                  Positioned(top: -30, right: -30,
                      child: _circle(120, 0.07)),
                  Positioned(bottom: -20, left: -20,
                      child: _circle(90, 0.05)),
                ],
              ),
              title: const Text('Student Records',
                  style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: Colors.white)),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
            ),
            actions: [
              // Upload CSV button
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _uploading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        tooltip: 'Upload CSV',
                        icon: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.upload_file_rounded,
                              color: Colors.white, size: 20),
                        ),
                        onPressed: _uploadCSV,
                      ),
              ),
            ],
          ),
        ],
        body: Column(
          children: [
            // ── Search bar ──────────────────────────────────────────
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: _kBlueBorder, width: 1),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x0A1565C0),
                        blurRadius: 10,
                        offset: Offset(0, 3)),
                  ],
                ),
                child: TextField(
                  onChanged: (v) =>
                      setState(() => _search = v.toLowerCase()),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search by name, admission no. or dept…',
                    hintStyle:
                        const TextStyle(color: _kGrey, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: _kBlue, size: 20),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ),

            // ── Student list ────────────────────────────────────────
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'student')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: _kBlue));
                  }

                  var docs = snapshot.data!.docs;

                  // Client-side search filter
                  if (_search.isNotEmpty) {
                    docs = docs.where((d) {
                      final data =
                          d.data() as Map<String, dynamic>;
                      return (data['name'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(_search) ||
                          (data['admissionNo'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(_search) ||
                          (data['department'] ?? '')
                              .toString()
                              .toLowerCase()
                              .contains(_search);
                    }).toList();
                  }

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 64,
                              color: _kBlue.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text(
                            _search.isEmpty
                                ? 'No students found'
                                : 'No results for "$_search"',
                            style: const TextStyle(
                                color: _kGrey, fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        16, 4, 16, 24),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final d = docs[index].data()
                          as Map<String, dynamic>;
                      final docId =
                          docs[index].id;
                      final name =
                          d['name'] ?? '—';

                      return _StudentCard(
                        data: d,
                        onDelete: () =>
                            _deleteStudent(context, docId, name),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // ── FAB: CSV format hint ──────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploading ? null : _uploadCSV,
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.upload_rounded),
        label: const Text('Upload CSV',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  static Widget _circle(double size, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );
}

// ── Student Card ──────────────────────────────────────────────────────────────
class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onDelete;
  const _StudentCard({required this.data, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final name        = data['name']        ?? '—';
    final admissionNo = data['admissionNo'] ?? '—';
    final dept        = data['department']  ?? '—';
    final sem         = data['semester']    ?? '—';
    final ktuid       = data['ktuid']       ?? '—';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: _kBlueBorder.withOpacity(0.5), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1565C0),
              blurRadius: 10,
              offset: Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  _initials(name),
                  style: const TextStyle(
                      color: _kBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _kDark)),
                  const SizedBox(height: 4),
                  _infoRow(Icons.confirmation_number_rounded,
                      admissionNo),
                  const SizedBox(height: 2),
                  _infoRow(Icons.school_rounded, '$dept · $sem'),
                  const SizedBox(height: 2),
                  _infoRow(Icons.fingerprint_rounded, ktuid),
                ],
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 13, color: _kGrey),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12,
                    color: _kGrey,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );

  static String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}