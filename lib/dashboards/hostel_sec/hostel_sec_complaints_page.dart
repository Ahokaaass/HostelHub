import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hostel_sec_complaint_detail_page.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

// ── Helpers ───────────────────────────────────────────────────────────────────
_StatusStyle _resolveStatus(String status) {
  switch (status.toLowerCase()) {
    case 'resolved':
      return _StatusStyle(
          color: Colors.green.shade600,
          bg   : Colors.green.shade50,
          label: 'Resolved',
          icon : Icons.check_circle_rounded);
    case 'in progress':
      return _StatusStyle(
          color: Colors.orange.shade700,
          bg   : Colors.orange.shade50,
          label: 'In Progress',
          icon : Icons.autorenew_rounded);
    default:
      return _StatusStyle(
          color: _kBlue,
          bg   : _kBlueTint,
          label: 'Submitted',
          icon : Icons.schedule_rounded);
  }
}

IconData _categoryIcon(String cat) {
  switch (cat.toLowerCase()) {
    case 'room complaint'   : return Icons.bedroom_parent_rounded;
    case 'mess complaint'   : return Icons.restaurant_rounded;
    case 'general complaint': return Icons.report_problem_rounded;
    default                 : return Icons.info_outline_rounded;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class HostelSecComplaintsPage extends StatefulWidget {
  const HostelSecComplaintsPage({super.key});

  @override
  State<HostelSecComplaintsPage> createState() =>
      _HostelSecComplaintsPageState();
}

class _HostelSecComplaintsPageState
    extends State<HostelSecComplaintsPage> {
  String _filter = 'All';
  final _filters = ['All', 'Submitted', 'In Progress', 'Resolved'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(),

          // ── Filter chips ─────────────────────────────────────────
          Container(
            color  : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child  : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final sel = _filter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? _kBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: sel ? _kBlue : _kBorder,
                              width: 1.2),
                          boxShadow: sel
                              ? [BoxShadow(
                                  color : _kBlue.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3))]
                              : [],
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize  : 13,
                                fontWeight: FontWeight.w600,
                                color: sel ? Colors.white : _kSubtext)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF0F4FF)),

          // ── List ─────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }

                var docs = snap.data!.docs;
                if (_filter != 'All') {
                  docs = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return (data['status'] ?? '')
                        .toString()
                        .toLowerCase() ==
                        _filter.toLowerCase();
                  }).toList();
                }

                if (docs.isEmpty) {
                  return _emptyState(_filter == 'All'
                      ? 'No complaints found'
                      : 'No $_filter complaints');
                }

                return ListView.builder(
                  padding    : const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount  : docs.length,
                  itemBuilder: (ctx, i) {
                    final data  = docs[i].data() as Map<String, dynamic>;
                    final docId = docs[i].id;
                    return _ComplaintCard(
                      data : data,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HostelSecComplaintDetailPage(
                              data: data, docId: docId),
                        ),
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

  Widget _buildHeader() => Container(
        width  : double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end  : Alignment.bottomRight,
            colors: [_kBlue, _kBlueLight],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width : 36, height: 36,
                decoration: BoxDecoration(
                  color       : Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complaints',
                    style: TextStyle(
                        color     : Colors.white,
                        fontSize  : 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3)),
                SizedBox(height: 2),
                Text('All hostel complaint records',
                    style:
                        TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ]),
        ),
      );

  static Widget _emptyState(String msg) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.inbox_rounded,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 14),
          Text(msg,
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 15)),
        ]),
      );
}

// ── Complaint Card ────────────────────────────────────────────────────────────
class _ComplaintCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _ComplaintCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final category = data['category']    ?? 'Complaint';
    final room     = data['room']        ?? data['admissionNo'] ?? '—';
    final message  = data['message']     ?? data['description'] ?? '—';
    final status   = data['status']      ?? 'Submitted';
    final name     = data['name']        ?? 'Student';
    final style    = _resolveStatus(status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: _kBorder.withOpacity(0.6), width: 1),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0A1565C0),
                blurRadius: 10,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(children: [
          // Color accent bar
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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(children: [
                  Container(
                    width : 38, height: 38,
                    decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(_categoryIcon(category),
                        color: _kBlue, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(category,
                        style: const TextStyle(
                            fontSize  : 14,
                            fontWeight: FontWeight.w700,
                            color     : _kText)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color       : style.bg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(style.icon,
                            size: 11, color: style.color),
                        const SizedBox(width: 4),
                        Text(style.label,
                            style: TextStyle(
                                fontSize  : 11,
                                fontWeight: FontWeight.w700,
                                color     : style.color)),
                      ],
                    ),
                  ),
                ]),

                const SizedBox(height: 10),

                // Message preview
                Text(message,
                    maxLines : 2,
                    overflow : TextOverflow.ellipsis,
                    style    : TextStyle(
                        fontSize: 13,
                        color   : Colors.grey.shade600,
                        height  : 1.4)),

                const SizedBox(height: 10),

                // Meta + arrow
                Row(children: [
                  _meta(Icons.person_rounded, name),
                  const SizedBox(width: 14),
                  _meta(Icons.meeting_room_rounded, 'Room $room'),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 13, color: _kSubtext),
                ]),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  static Widget _meta(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _kSubtext),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                  fontSize  : 12,
                  color     : _kSubtext,
                  fontWeight: FontWeight.w500)),
        ],
      );
}

// ── Status style model ────────────────────────────────────────────────────────
class _StatusStyle {
  final Color    color;
  final Color    bg;
  final String   label;
  final IconData icon;
  const _StatusStyle({
    required this.color,
    required this.bg,
    required this.label,
    required this.icon,
  });
}