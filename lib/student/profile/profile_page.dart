import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'edit_profile.dart';
import '../../screens/login_screen.dart';

// ── Blue palette (mirrors StudentDashboard) ───────────────────────────────────
const _kBlue       = Color(0xFF1565C0);
const _kBlueLight  = Color(0xFF1E88E5);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kBg         = Color(0xFFF5F8FF);
const _kDark       = Color(0xFF1A1A2E);
const _kGrey       = Color(0xFF6B7280);

class ProfilePage extends StatefulWidget {
  final String admissionNo;
  const ProfilePage({super.key, required this.admissionNo});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          .child('profile_pics/${widget.admissionNo}.jpg');

      await ref.putFile(file);
      final url = await ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.admissionNo)
          .update({'photoUrl': url});

      if (mounted) {
        _showSnack('Profile photo updated!', Colors.green.shade600);
      }
    } catch (_) {
      if (mounted) {
        _showSnack('Failed to upload photo. Try again.', Colors.red.shade600);
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  void _showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.admissionNo)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: _kBlue));
          }

          final d        = snapshot.data!.data() as Map<String, dynamic>;
          final name     = d['name']     ?? '';
          final email    = d['email']    ?? '';
          final dept     = d['department'] ?? '';
          final sem      = d['semester'] ?? '';
          final photoUrl = d['photoUrl'] as String?;

          return CustomScrollView(
            slivers: [
              // ── Hero header ───────────────────────────────────────
              SliverAppBar(
                expandedHeight: 260,
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
                      // Avatar + info
                      Positioned(
                        bottom: 28, left: 0, right: 0,
                        child: Column(children: [
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
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  )],
                                ),
                                child: ClipOval(
                                  child: _uploadingPhoto
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                              color: _kBlue, strokeWidth: 2.5))
                                      : (photoUrl != null && photoUrl.isNotEmpty)
                                          ? Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              width: 90,
                                              height: 90,
                                              errorBuilder: (_, __, ___) =>
                                                  _initialsView(name),
                                            )
                                          : _initialsView(name),
                                ),
                              ),
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
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                    )],
                                  ),
                                  child: const Icon(Icons.camera_alt_rounded,
                                      size: 15, color: _kBlue),
                                ),
                              ),
                            ]),
                          ),
                          const SizedBox(height: 10),
                          Text(name, style: const TextStyle(
                              color: Colors.white, fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3)),
                          const SizedBox(height: 3),
                          Text('$dept · $sem', style: TextStyle(
                              color: Colors.white.withOpacity(0.82),
                              fontSize: 13, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(email, style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12)),
                        ]),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Wrap(spacing: 10, runSpacing: 10, children: [
                        _Chip(Icons.badge_rounded,
                            d['admissionNo'] ?? ''),
                        _Chip(Icons.fingerprint_rounded,
                            d['ktuid'] ?? ''),
                        _Chip(Icons.meeting_room_rounded,
                            'Room ${d['room'] ?? ''}'),
                      ]),

                      const SizedBox(height: 22),

                      _label('Academic Info'),
                      const SizedBox(height: 12),
                      _Card(rows: [
                        _R(Icons.school_rounded, 'Department',
                            d['department'] ?? '—'),
                        _R(Icons.class_rounded, 'Semester',
                            d['semester'] ?? '—'),
                        _R(Icons.door_front_door_rounded, 'Room No.',
                            '${d['room'] ?? '—'}'),
                        _R(Icons.calendar_today_rounded, 'Date of Admission',
                            d['dateOfAdmission'] ?? '—'),
                      ]),

                      const SizedBox(height: 18),

                      _label('Contact Info'),
                      const SizedBox(height: 12),
                      _Card(rows: [
                        _R(Icons.email_rounded, 'Email',
                            d['email'] ?? '—'),
                        _R(Icons.phone_rounded, 'Phone',
                            d['phone'] ?? '—'),
                      ]),

                      const SizedBox(height: 18),

                      _label('Parent / Guardian'),
                      const SizedBox(height: 12),
                      _Card(rows: [
                        _R(Icons.person_rounded, 'Name',
                            d['parentName'] ?? '—'),
                        _R(Icons.phone_callback_rounded, 'Phone',
                            d['parentPhone'] ?? '—'),
                        _R(Icons.mark_email_read_rounded, 'Email',
                            d['parentEmail'] ?? '—'),
                      ]),

                      const SizedBox(height: 28),

                      _Btn(
                        icon: Icons.edit_rounded,
                        label: 'Edit Profile',
                        bg: _kBlue,
                        fg: Colors.white,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfilePage(
                              admissionNo: widget.admissionNo,
                              data: d,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _Btn(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        bg: Colors.white,
                        fg: Colors.red.shade600,
                        border: Colors.red.shade200,
                        onTap: () => _confirmLogout(context),
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
          fontSize: 15, fontWeight: FontWeight.w800,
          color: _kDark, letterSpacing: -0.2));
}

// ── Small widgets ─────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Chip(this.icon, this.label);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kBlueTint,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _kBlueBorder, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: _kBlue),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600,
                  color: _kBlue)),
        ]),
      );
}

class _R {
  final IconData icon;
  final String label, value;
  const _R(this.icon, this.label, this.value);
}

class _Card extends StatelessWidget {
  final List<_R> rows;
  const _Card({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kBlueBorder.withOpacity(0.5), width: 1),
        boxShadow: const [
          BoxShadow(color: Color(0x0A1565C0), blurRadius: 14,
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
                Expanded(child: Text(r.label,
                    style: const TextStyle(fontSize: 13,
                        color: _kGrey, fontWeight: FontWeight.w500))),
                Flexible(child: Text(r.value,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: _kDark))),
              ]),
            ),
            if (i < rows.length - 1)
              const Divider(height: 1, indent: 60,
                  color: Color(0xFFF0F4FF)),
          ]);
        }),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg, fg;
  final Color? border;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.label,
      required this.bg, required this.fg, required this.onTap,
      this.border});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(label, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700)),
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            elevation: 0,
            side: border != null
                ? BorderSide(color: border!, width: 1.5)
                : BorderSide.none,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}