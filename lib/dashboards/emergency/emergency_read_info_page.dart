import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'emergency_model.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class EmergencyReadInfoPage extends StatefulWidget {
  final EmergencyModel emergency;

  const EmergencyReadInfoPage({super.key, required this.emergency});

  @override
  State<EmergencyReadInfoPage> createState() => _EmergencyReadInfoPageState();
}

class _EmergencyReadInfoPageState extends State<EmergencyReadInfoPage> {
  // State
  bool              _loading = true;
  String?           _error;
  List<_UserInfo>   _readUsers   = [];
  List<_UserInfo>   _unreadUsers = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      // ── 1. Get readBy list ─────────────────────────────────────────────
      // Try from the passed model first, then fetch from Firestore if needed
      List<String> readBy = [];

      if (widget.emergency.id.isNotEmpty) {
        try {
          final doc = await FirebaseFirestore.instance
              .collection('emergencies')
              .doc(widget.emergency.id)
              .get();
          if (doc.exists) {
            readBy = List<String>.from(doc.data()?['readBy'] ?? []);
          }
        } catch (_) {
          // If fetching the specific doc fails, readBy stays empty
        }
      }

      final List<_UserInfo> readUsers   = [];
      final List<_UserInfo> unreadUsers = [];

      // ── 2. Fetch users collection ──────────────────────────────────────
      try {
        final usersSnap = await FirebaseFirestore.instance
            .collection('users')
            .get();

        for (final doc in usersSnap.docs) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().trim();
          if (name.isEmpty) continue; // skip blank docs

          final user = _UserInfo(
            id     : doc.id,
            name   : name,
            detail : _detail(
              room: (data['roomNumber'] ?? data['room'] ?? '').toString(),
              dept: (data['department'] ?? data['dept'] ?? '').toString(),
            ),
            roleTag: 'Student',
          );

          if (readBy.contains(doc.id)) {
            readUsers.add(user);
          } else {
            unreadUsers.add(user);
          }
        }
      } catch (e) {
        debugPrint('Error fetching users: $e');
      }

      // ── 3. Fetch staff collection ──────────────────────────────────────
      try {
        final staffSnap = await FirebaseFirestore.instance
            .collection('staff')
            .get();

        for (final doc in staffSnap.docs) {
          final data = doc.data();
          final name = (data['name'] ?? '').toString().trim();
          if (name.isEmpty) continue;

          final roleRaw = (data['role'] ?? 'staff').toString();
          final user = _UserInfo(
            id     : doc.id,
            name   : name,
            detail : _capitalise(roleRaw),
            roleTag: _capitalise(roleRaw),
          );

          if (readBy.contains(doc.id)) {
            readUsers.add(user);
          } else {
            unreadUsers.add(user);
          }
        }
      } catch (e) {
        debugPrint('Error fetching staff: $e');
      }

      if (mounted) {
        setState(() {
          _readUsers   = readUsers;
          _unreadUsers = unreadUsers;
          _loading     = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error   = e.toString();
          _loading = false;
        });
      }
    }
  }

  static String _detail({required String room, required String dept}) {
    final parts = <String>[];
    if (room.isNotEmpty) parts.add('Room $room');
    if (dept.isNotEmpty) parts.add(dept);
    return parts.isEmpty ? 'Student' : parts.join(' · ');
  }

  static String _capitalise(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
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
                  offset    : Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Read Info',
                              style: TextStyle(
                                  color        : Colors.white,
                                  fontSize     : 20,
                                  fontWeight   : FontWeight.w800,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 2),
                          Text(
                            widget.emergency.title.isNotEmpty
                                ? widget.emergency.title
                                : 'Emergency Alert',
                            maxLines : 1,
                            overflow : TextOverflow.ellipsis,
                            style: const TextStyle(
                                color   : Colors.white70,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Refresh button
                    GestureDetector(
                      onTap: () {
                        setState(() => _loading = true);
                        _load();
                      },
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    // Loading
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _kBlue),
            SizedBox(height: 16),
            Text('Loading read info...',
                style: TextStyle(color: _kSubtext, fontSize: 13)),
          ],
        ),
      );
    }

    // Error
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width : 64,
                height: 64,
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.error_outline_rounded,
                    color: Colors.red.shade600, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Failed to load',
                  style: TextStyle(
                      fontSize  : 16,
                      fontWeight: FontWeight.w700,
                      color     : _kText)),
              const SizedBox(height: 8),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 12, color: _kSubtext)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _loading = true;
                    _error   = null;
                  });
                  _load();
                },
                icon : const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty — no users found at all
    if (_readUsers.isEmpty && _unreadUsers.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width : 64,
              height: 64,
              decoration: BoxDecoration(
                  color: _kBlueTint,
                  borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.people_outline_rounded,
                  color: _kBlue, size: 32),
            ),
            const SizedBox(height: 16),
            const Text('No users found',
                style: TextStyle(
                    fontSize  : 16,
                    fontWeight: FontWeight.w600,
                    color     : _kText)),
            const SizedBox(height: 4),
            const Text('No data available in users/staff collections',
                style: TextStyle(fontSize: 12, color: _kSubtext)),
          ],
        ),
      );
    }

    // ── Main list ──────────────────────────────────────────────────────────
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
      children: [
        // Summary row
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SummaryChip(
              icon : Icons.done_all_rounded,
              label: '${_readUsers.length} Read',
              color: Colors.green.shade600,
              bg   : Colors.green.shade50,
            ),
            _SummaryChip(
              icon : Icons.schedule_rounded,
              label: '${_unreadUsers.length} Not Read',
              color: _kSubtext,
              bg   : const Color(0xFFF3F4F6),
            ),
            _SummaryChip(
              icon : Icons.people_rounded,
              label:
                  '${_readUsers.length + _unreadUsers.length} Total',
              color: _kBlue,
              bg   : _kBlueTint,
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Read section
        if (_readUsers.isNotEmpty) ...[
          _SectionHeader(
            icon : Icons.done_all_rounded,
            label: 'Read',
            color: Colors.green.shade600,
            count: _readUsers.length,
          ),
          const SizedBox(height: 10),
          ..._readUsers.map((u) => _UserTile(user: u, isRead: true)),
          const SizedBox(height: 20),
        ],

        // Not read section
        if (_unreadUsers.isNotEmpty) ...[
          _SectionHeader(
            icon : Icons.schedule_rounded,
            label: 'Not Read',
            color: _kSubtext,
            count: _unreadUsers.length,
          ),
          const SizedBox(height: 10),
          ..._unreadUsers
              .map((u) => _UserTile(user: u, isRead: false)),
        ],
      ],
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────
class _UserInfo {
  final String id;
  final String name;
  final String detail;
  final String roleTag;

  const _UserInfo({
    required this.id,
    required this.name,
    required this.detail,
    required this.roleTag,
  });
}

// ── Widgets ───────────────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final Color    bg;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color       : bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 12,
                  color     : color)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final int      count;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 6),
        Text('$label ($count)',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize  : 13,
                color     : color)),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final _UserInfo user;
  final bool      isRead;

  const _UserTile({required this.user, required this.isRead});

  Color get _tagColor {
    switch (user.roleTag.toLowerCase()) {
      case 'warden'  : return const Color(0xFF6A1B9A);
      case 'matron'  : return const Color(0xFF00838F);
      case 'admin'   : return const Color(0xFFBF360C);
      case 'security': return const Color(0xFF37474F);
      case 'rt'      : return const Color(0xFF1565C0);
      default        : return const Color(0xFF2E7D32);
    }
  }

  Color get _tagBg {
    switch (user.roleTag.toLowerCase()) {
      case 'warden'  : return const Color(0xFFF3E5F5);
      case 'matron'  : return const Color(0xFFE0F7FA);
      case 'admin'   : return const Color(0xFFFBE9E7);
      case 'security': return const Color(0xFFECEFF1);
      case 'rt'      : return const Color(0xFFE8F0FE);
      default        : return const Color(0xFFE8F5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border      : Border.all(color: _kBorder, width: 1.2),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0A1565C0),
              blurRadius: 8,
              offset    : Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width : 44,
            height: 44,
            decoration: BoxDecoration(
              color: isRead
                  ? Colors.green.shade50
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize  : 17,
                    color     : isRead
                        ? Colors.green.shade600
                        : _kSubtext),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                        color     : _kText)),
                const SizedBox(height: 3),
                Text(user.detail,
                    style: const TextStyle(
                        fontSize: 11, color: _kSubtext)),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Role pill
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color       : _tagBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(user.roleTag,
                style: TextStyle(
                    fontSize  : 10,
                    fontWeight: FontWeight.w700,
                    color     : _tagColor)),
          ),

          const SizedBox(width: 8),

          // Read indicator
          Icon(
            isRead
                ? Icons.done_all_rounded
                : Icons.schedule_rounded,
            size : 18,
            color: isRead ? Colors.green.shade600 : _kSubtext,
          ),
        ],
      ),
    );
  }
}