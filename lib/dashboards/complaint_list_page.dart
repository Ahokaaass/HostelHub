import 'package:flutter/material.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class ComplaintListPage extends StatefulWidget {
  const ComplaintListPage({super.key});

  @override
  State<ComplaintListPage> createState() => _ComplaintListPageState();
}

class _ComplaintListPageState extends State<ComplaintListPage> {
  List<Map<String, String>> complaints = [
    {"student": "Rahul",  "room": "301", "issue": "Fan not working"},
    {"student": "Anjali", "room": "108", "issue": "Water leakage"},
  ];

  // ── Forward ───────────────────────────────────────────────────────────────
  void _confirmApprove(int index) {
    _showConfirmDialog(
      title        : 'Forward Complaint',
      message      :
          'Forward this complaint from ${complaints[index]['student']}?',
      confirmLabel : 'Forward',
      confirmColor : _kBlue,
      onConfirm    : () {
        setState(() => complaints.removeAt(index));
        _showSnack('Complaint forwarded successfully');
      },
    );
  }

  // ── Reject ────────────────────────────────────────────────────────────────
  void _confirmReject(int index) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Reject Complaint',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Please provide a reason for rejection.',
                style: TextStyle(color: _kSubtext, fontSize: 13)),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(fontSize: 14, color: _kText),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason…',
                hintStyle:
                    const TextStyle(color: _kSubtext, fontSize: 13),
                filled    : true,
                fillColor : _kBg,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide  : const BorderSide(color: _kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide  : const BorderSide(color: _kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide  :
                      const BorderSide(color: _kBlue, width: 1.5),
                ),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side : const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => complaints.removeAt(index));
              _showSnack('Complaint rejected');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  // ── Shared confirm dialog ─────────────────────────────────────────────────
  void _showConfirmDialog({
    required String title,
    required String message,
    required String confirmLabel,
    required Color  confirmColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Text(message,
            style: const TextStyle(color: _kSubtext, fontSize: 14)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            style: OutlinedButton.styleFrom(
              side : const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size : 18,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.shade600
            : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
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
                      children: [
                        const Text('Complaints',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        Text(
                          '${complaints.length} pending complaint${complaints.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                              color  : Colors.white70,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: complaints.isEmpty
                ? Center(
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
                          child: const Icon(
                              Icons.mark_chat_read_rounded,
                              color: _kBlue,
                              size : 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No complaints',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('All complaints have been resolved',
                            style: TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.fromLTRB(20, 24, 20, 36),
                    itemCount: complaints.length,
                    itemBuilder: (context, index) {
                      final c = complaints[index];
                      return _ComplaintCard(
                        student : c['student']!,
                        room    : c['room']!,
                        issue   : c['issue']!,
                        onForward: () => _confirmApprove(index),
                        onReject : () => _confirmReject(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Complaint card ────────────────────────────────────────────────────────────
class _ComplaintCard extends StatelessWidget {
  final String      student;
  final String      room;
  final String      issue;
  final VoidCallback onForward;
  final VoidCallback onReject;

  const _ComplaintCard({
    required this.student,
    required this.room,
    required this.issue,
    required this.onForward,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            children: [
              Container(
                width : 42,
                height: 42,
                decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_rounded,
                    color: _kBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize  : 14,
                            color     : _kText)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_rounded,
                            size: 12, color: _kSubtext),
                        const SizedBox(width: 4),
                        Text('Room $room',
                            style: const TextStyle(
                                fontSize: 12, color: _kSubtext)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color       : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text('Pending',
                    style: TextStyle(
                        fontSize  : 11,
                        fontWeight: FontWeight.w700,
                        color     : Colors.orange.shade700)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Issue box
          Container(
            width  : double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color       : _kBg,
              borderRadius: BorderRadius.circular(12),
              border      : Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Icon(Icons.report_problem_rounded,
                    size: 16, color: _kSubtext),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(issue,
                      style: const TextStyle(
                          fontSize: 13, color: _kText)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onReject,
                  icon : Icon(Icons.cancel_outlined,
                      size: 16, color: Colors.red.shade600),
                  label: Text('Reject',
                      style: TextStyle(
                          color    : Colors.red.shade600,
                          fontSize : 13,
                          fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.shade200),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onForward,
                  icon : const Icon(
                      Icons.forward_to_inbox_rounded,
                      size: 16),
                  label: const Text('Forward',
                      style: TextStyle(
                          fontSize  : 13,
                          fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}