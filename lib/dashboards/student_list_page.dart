import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class StudentListPage extends StatelessWidget {
  const StudentListPage({super.key});

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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Student Records',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('All registered hostel students',
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

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('name')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: _kBlue),
                  );
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
                          child: const Icon(Icons.people_outline_rounded,
                              color: _kBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No students found',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('Students will appear here once registered',
                            style: TextStyle(color: _kSubtext, fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _StudentCard(data: data);
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

class _StudentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _StudentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Container(
            width : 48,
            height: 48,
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded,
                color: _kBlue, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? 'No Name',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize  : 14,
                      color     : _kText),
                ),
                const SizedBox(height: 6),
                _infoRow(Icons.school_rounded,
                    'Dept: ${data['department'] ?? '-'}'),
                const SizedBox(height: 3),
                _infoRow(Icons.layers_rounded,
                    'Semester: ${data['semester'] ?? '-'}'),
                const SizedBox(height: 3),
                _infoRow(Icons.meeting_room_rounded,
                    'Room: ${data['room'] ?? '-'}'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.chevron_right_rounded,
                color: _kBlue, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 12, color: _kSubtext),
          const SizedBox(width: 5),
          Text(text,
              style: const TextStyle(fontSize: 12, color: _kSubtext)),
        ],
      );
}