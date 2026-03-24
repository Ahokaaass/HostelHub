import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'emergency_model.dart';
import '../../../student/student_data.dart'; // adjust path as needed

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

/// Student-facing emergency list — read-only.
/// Opening this page marks ALL unread emergencies as read for this user.
class StudentEmergencyPage extends StatefulWidget {
  const StudentEmergencyPage({super.key});

  @override
  State<StudentEmergencyPage> createState() => _StudentEmergencyPageState();
}

class _StudentEmergencyPageState extends State<StudentEmergencyPage> {
  @override
  void initState() {
    super.initState();
    _markAllRead();
  }

  /// Adds the current userId to readBy on every emergency doc they haven't read.
  Future<void> _markAllRead() async {
    final userId = StudentData.admissionNo;
    final snap = await FirebaseFirestore.instance
        .collection('emergencies')
        .get();
    for (final doc in snap.docs) {
      final data  = doc.data();
      final readBy = List<String>.from(data['readBy'] ?? []);
      if (!readBy.contains(userId)) {
        await doc.reference.update({
          'readBy': [...readBy, userId],
        });
      }
    }
  }

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Emergency Alerts',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Active hostel emergency updates',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('emergencies')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.shield_rounded,
                              color: _kBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No emergency alerts',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('All clear — no active emergencies',
                            style: TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final emergency =
                        EmergencyModel.fromDoc(docs[index]);
                    return _StudentEmergencyCard(emergency: emergency);
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

// ── Student emergency card (view-only, no action buttons) ────────────────────
class _StudentEmergencyCard extends StatelessWidget {
  final EmergencyModel emergency;

  const _StudentEmergencyCard({required this.emergency});

  @override
  Widget build(BuildContext context) {
    final style = _resolveStyle(emergency.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border      : Border.all(color: _kBorder, width: 1.2),
        boxShadow   : const [
          BoxShadow(
              color     : Color(0x0C1565C0),
              blurRadius: 12,
              offset    : Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Colored top accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: style.color,
              borderRadius: const BorderRadius.only(
                topLeft : Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: icon + title + status badge
                Row(
                  children: [
                    Container(
                      width : 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color       : style.tint,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(style.icon,
                          color: style.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(emergency.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 14,
                              color     : _kText)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color : style.tint,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: style.color.withOpacity(0.4)),
                      ),
                      child: Text(style.label,
                          style: TextStyle(
                              fontSize  : 11,
                              fontWeight: FontWeight.w800,
                              color     : style.color,
                              letterSpacing: 0.3)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Message
                Container(
                  width  : double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color       : _kBg,
                    borderRadius: BorderRadius.circular(12),
                    border      : Border.all(color: _kBorder),
                  ),
                  child: Text(emergency.message,
                      style: const TextStyle(
                          fontSize: 13, color: _kSubtext)),
                ),

                const SizedBox(height: 12),

                // Severity chip only — no action buttons
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: style.tint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bar_chart_rounded,
                              size: 12, color: style.color),
                          const SizedBox(width: 4),
                          Text(
                            'Severity: ${emergency.severity}',
                            style: TextStyle(
                                fontSize  : 11,
                                fontWeight: FontWeight.w600,
                                color     : style.color),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _resolveStyle(String status) {
    switch (status) {
      case 'handled':
        return _StatusStyle(
            color: Colors.green.shade600,
            tint : Colors.green.shade50,
            icon : Icons.check_circle_rounded,
            label: 'RESOLVED');
      case 'received':
        return _StatusStyle(
            color: Colors.orange.shade700,
            tint : Colors.orange.shade50,
            icon : Icons.access_time_rounded,
            label: 'RECEIVED');
      default:
        return _StatusStyle(
            color: Colors.red.shade600,
            tint : Colors.red.shade50,
            icon : Icons.warning_rounded,
            label: 'ACTIVE');
    }
  }
}

class _StatusStyle {
  final Color    color;
  final Color    tint;
  final IconData icon;
  final String   label;

  const _StatusStyle({
    required this.color,
    required this.tint,
    required this.icon,
    required this.label,
  });
}