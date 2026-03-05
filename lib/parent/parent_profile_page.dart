import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../core/session.dart';
import '../screens/login_screen.dart';
import '../student/student_data.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue       = Color(0xFF1565C0);
const _kBlueLight  = Color(0xFF1E88E5);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg         = Color(0xFFF5F8FF);
const _kDark       = Color(0xFF1A1A2E);
const _kGrey       = Color(0xFF6B7280);

class ParentProfilePage extends StatefulWidget {
  ParentProfilePage({super.key});

  @override
  State<ParentProfilePage> createState() => _ParentProfilePageState();
}

class _ParentProfilePageState extends State<ParentProfilePage> {
  final String _parentId = Session.userId ?? '';
  bool _uploadingPhoto = false;

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 600,
    );
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      final file = File(picked.path);
      final ref  = FirebaseStorage.instance
          .ref()
          .child('parent_profile_pics/$_parentId.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('parents')
          .doc(_parentId)
          .update({'photoUrl': url});

      if (mounted) _showSnack('Profile photo updated!', Colors.green.shade600);
    } catch (_) {
      if (mounted)
        _showSnack('Failed to upload photo. Try again.', Colors.red.shade600);
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
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

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
            onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('parents')
            .doc(_parentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _kBlue));
          }

          final p        = snapshot.data!.data() as Map<String, dynamic>;
          final name     = p['parentName'] ?? 'Parent';
          final phone    = p['parentPhone'] ?? '';
          final email    = p['parentEmail'] ?? '';
          final photoUrl = p['photoUrl'] as String?;

          return CustomScrollView(
            slivers: [
              // ── Hero Header ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 250,
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
                      Positioned(top: -40, right: -40,
                          child: _circle(160, 0.07)),
                      Positioned(bottom: -30, left: -20,
                          child: _circle(120, 0.05)),
                      Positioned(top: 70, right: 80,
                          child: _circle(50, 0.04)),

                      // Avatar + name
                      Positioned(
                        bottom: 28, left: 0, right: 0,
                        child: Column(children: [
                          // Tappable avatar
                          GestureDetector(
                            onTap: _uploadingPhoto
                                ? null
                                : _pickAndUploadPhoto,
                            child: Stack(children: [
                              Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(
                                    color:
                                        Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )],
                                ),
                                child: ClipOval(
                                  child: _uploadingPhoto
                                      ? const Center(
                                          child:
                                              CircularProgressIndicator(
                                                  color: _kBlue,
                                                  strokeWidth: 2.5))
                                      : (photoUrl != null &&
                                              photoUrl.isNotEmpty)
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              width: 90, height: 90,
                                              errorBuilder:
                                                  (_, __, ___) =>
                                                      _initialsView(
                                                          name),
                                            )
                                          : _initialsView(name),
                                ),
                              ),
                              // Camera badge
                              Positioned(
                                bottom: 0, right: 0,
                                child: Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _kBlueTint, width: 2),
                                    boxShadow: [BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.15),
                                      blurRadius: 4,
                                    )],
                                  ),
                                  child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 15,
                                      color: _kBlue),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 10),
                          Text(name,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 4),
                          // "Parent" pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(0.18),
                              borderRadius:
                                  BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.white
                                      .withOpacity(0.35),
                                  width: 1),
                            ),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.family_restroom_rounded,
                                      size: 13,
                                      color: Colors.white
                                          .withOpacity(0.9)),
                                  const SizedBox(width: 5),
                                  Text('Parent / Guardian',
                                      style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.95),
                                          fontSize: 12,
                                          fontWeight:
                                              FontWeight.w600)),
                                ]),
                          ),
                          const SizedBox(height: 5),
                          Text(phone,
                              style: TextStyle(
                                  color:
                                      Colors.white.withOpacity(0.65),
                                  fontSize: 12)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Parent info card ─────────────────────────
                      _label('Parent Info'),
                      const SizedBox(height: 12),
                      _InfoCard(rows: [
                        _R(Icons.person_rounded, 'Name', name),
                        _R(Icons.phone_rounded, 'Phone', phone),
                        _R(Icons.email_rounded, 'Email', email),
                      ]),

                      const SizedBox(height: 18),

                      // ── Linked student card ──────────────────────
                      _label('Linked Student'),
                      const SizedBox(height: 12),
                      _InfoCard(rows: [
                        _R(Icons.person_outline_rounded,
                            'Student Name', StudentData.name),
                        _R(Icons.confirmation_number_rounded,
                            'Admission No', StudentData.admissionNo),
                        _R(Icons.school_rounded,
                            'Department',
                            StudentData.department ?? 'N/A'),
                        _R(Icons.meeting_room_rounded,
                            'Room',
                            '${StudentData.room ?? 'N/A'}'),
                      ]),

                      const SizedBox(height: 28),

                      // ── Photo note ───────────────────────────────
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: _kBlueTint,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: _kBlueBorder, width: 1),
                        ),
                        child: Row(children: [
                          const Icon(Icons.info_outline_rounded,
                              color: _kBlue, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Tap your profile photo above to update it. All other details are managed by the hostel administration.',
                              style: TextStyle(
                                  fontSize: 12.5,
                                  color: _kBlue.withOpacity(0.85),
                                  fontWeight: FontWeight.w500,
                                  height: 1.5),
                            ),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 20),

                      // ── Logout ───────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmLogout(context),
                          icon: const Icon(Icons.logout_rounded,
                              size: 18),
                          label: const Text('Logout',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.red.shade600,
                            elevation: 0,
                            side: BorderSide(
                                color: Colors.red.shade200, width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(14)),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _initialsView(String name) => Center(
        child: Text(_initials(name),
            style: const TextStyle(
                color: _kBlue, fontSize: 30, fontWeight: FontWeight.w800)),
      );

  static Widget _circle(double size, double opacity) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      );

  static Widget _label(String t) => Text(t,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: _kDark,
          letterSpacing: -0.2));
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _R {
  final IconData icon;
  final String label, value;
  const _R(this.icon, this.label, this.value);
}

class _InfoCard extends StatelessWidget {
  final List<_R> rows;
  const _InfoCard({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: _kBlueBorder.withOpacity(0.5), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1565C0),
              blurRadius: 14,
              offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 13),
              child: Row(children: [
                Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _kBlueTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(r.icon, color: _kBlue, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r.label,
                      style: const TextStyle(
                          fontSize: 13,
                          color: _kGrey,
                          fontWeight: FontWeight.w500)),
                ),
                Flexible(
                  child: Text(r.value,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _kDark)),
                ),
              ]),
            ),
            if (i < rows.length - 1)
              const Divider(
                  height: 1, indent: 60, color: Color(0xFFF0F4FF)),
          ]);
        }),
      ),
    );
  }
}