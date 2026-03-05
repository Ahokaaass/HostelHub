import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Blue palette ──────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

// ── Workflow steps in order ───────────────────────────────────────────────────
const _kSteps = [
  ('Submitted',        Icons.send_rounded),
  ('Hostel Secretary', Icons.admin_panel_settings_rounded),
  ('Matron',           Icons.medical_services_rounded),
  ('RT',               Icons.school_rounded),
  ('Warden',           Icons.security_rounded),
  ('Office Admin',     Icons.business_rounded),
];

// Maps status string → which step index is "current"
int _currentStep(String status) {
  switch (status.toLowerCase()) {
    case 'submitted'      : return 0;
    case 'hostel secretary': return 1;
    case 'matron'         : return 2;
    case 'rt'             : return 3;
    case 'warden'         : return 4;
    case 'resolved'       : return 5;
    default               : return 0;
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
class HostelSecComplaintDetailPage extends StatelessWidget {
  final Map<String, dynamic> data;
  final String docId;

  const HostelSecComplaintDetailPage({
    super.key,
    required this.data,
    required this.docId,
  });

  @override
  Widget build(BuildContext context) {
    final category = data['category'] ?? 'Complaint';
    final room     = data['room']     ?? data['admissionNo'] ?? '—';
    final message  = data['message']  ?? data['description'] ?? '—';
    final status   = data['status']   ?? 'Submitted';
    final name     = data['name']     ?? 'Student';
    final dept     = data['department'] ?? '';
    final phone    = data['phone']    ?? '';

    final stepIdx  = _currentStep(status);

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(children: [
        _buildHeader(context, category),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Status badge + category ─────────────────────────
                _statusBadge(status),
                const SizedBox(height: 20),

                // ── Student info card ───────────────────────────────
                _sectionLabel('Student Info'),
                const SizedBox(height: 10),
                _InfoCard(rows: [
                  _R(Icons.person_rounded, 'Name', name),
                  if (dept.isNotEmpty)
                    _R(Icons.school_rounded, 'Department', dept),
                  _R(Icons.meeting_room_rounded, 'Room', room),
                  if (phone.isNotEmpty)
                    _R(Icons.phone_rounded, 'Phone', phone),
                ]),

                const SizedBox(height: 20),

                // ── Complaint message ───────────────────────────────
                _sectionLabel('Complaint Message'),
                const SizedBox(height: 10),
                Container(
                  width  : double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color       : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _kBorder.withOpacity(0.5), width: 1),
                    boxShadow: const [
                      BoxShadow(
                          color     : Color(0x0A1565C0),
                          blurRadius: 10,
                          offset    : Offset(0, 3)),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width : 36, height: 36,
                        decoration: BoxDecoration(
                          color       : _kBlueTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_categoryIcon(category),
                            color: _kBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(message,
                            style: const TextStyle(
                                fontSize: 14,
                                color   : _kText,
                                height  : 1.5)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Progress tracker ────────────────────────────────
                _sectionLabel('Progress Tracker'),
                const SizedBox(height: 14),
                _ProgressTracker(currentStep: stepIdx),

                const SizedBox(height: 24),

                // ── Mark resolved button (only if not already) ──────
                if (status.toLowerCase() != 'resolved')
                  _MarkResolvedButton(docId: docId),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildHeader(BuildContext context, String category) =>
      Container(
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complaint Details',
                      style: TextStyle(
                          color     : Colors.white,
                          fontSize  : 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3)),
                  const SizedBox(height: 2),
                  Text(category,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
          ]),
        ),
      );

  Widget _statusBadge(String status) {
    Color color;
    Color bg;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'resolved':
        color = Colors.green.shade700; bg = Colors.green.shade50;
        icon  = Icons.check_circle_rounded; label = 'Resolved';
        break;
      case 'in progress':
        color = Colors.orange.shade700; bg = Colors.orange.shade50;
        icon  = Icons.autorenew_rounded; label = 'In Progress';
        break;
      default:
        color = _kBlue; bg = _kBlueTint;
        icon  = Icons.schedule_rounded; label = 'Submitted';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Text('Current Status:',
            style: TextStyle(
                fontSize  : 13,
                color     : color.withOpacity(0.7),
                fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Text(label,
            style: TextStyle(
                fontSize  : 14,
                fontWeight: FontWeight.w800,
                color     : color)),
      ]),
    );
  }

  static Widget _sectionLabel(String t) => Text(t,
      style: const TextStyle(
          fontSize     : 15,
          fontWeight   : FontWeight.w800,
          color        : _kText,
          letterSpacing: -0.2));
}

// ── Progress Tracker ──────────────────────────────────────────────────────────
class _ProgressTracker extends StatelessWidget {
  final int currentStep; // 0-based; steps up to this are "done"

  const _ProgressTracker({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: _kBorder.withOpacity(0.5), width: 1),
        boxShadow: const [
          BoxShadow(
              color     : Color(0x0A1565C0),
              blurRadius: 12,
              offset    : Offset(0, 4)),
        ],
      ),
      child: Column(
        children: List.generate(_kSteps.length, (i) {
          final (label, icon) = _kSteps[i];
          final isDone    = i <= currentStep;
          final isCurrent = i == currentStep;
          final isLast    = i == _kSteps.length - 1;

          return _StepRow(
            label    : label,
            icon     : icon,
            isDone   : isDone,
            isCurrent: isCurrent,
            isLast   : isLast,
          );
        }),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String   label;
  final IconData icon;
  final bool     isDone;
  final bool     isCurrent;
  final bool     isLast;

  const _StepRow({
    required this.label,
    required this.icon,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor  = isDone
        ? (isCurrent ? _kBlue : Colors.green.shade500)
        : Colors.grey.shade300;
    final Color lineColor = isDone && !isCurrent
        ? Colors.green.shade400
        : Colors.grey.shade200;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Left: dot + connector line ─────────────────────────────
        Column(children: [
          // Dot / icon circle
          Container(
            width : 40,
            height: 40,
            decoration: BoxDecoration(
              color : dotColor,
              shape : BoxShape.circle,
              boxShadow: isDone
                  ? [BoxShadow(
                      color     : dotColor.withOpacity(0.35),
                      blurRadius: 8,
                      offset    : const Offset(0, 2))]
                  : [],
            ),
            child: Icon(
              isDone && !isCurrent
                  ? Icons.check_rounded
                  : icon,
              color: isDone ? Colors.white : Colors.grey.shade400,
              size : 18,
            ),
          ),
          // Connector line
          if (!isLast)
            Container(
              width : 2,
              height: 36,
              margin: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color       : lineColor,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ]),

        const SizedBox(width: 14),

        // ── Right: label + badge ────────────────────────────────────
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                top: 10, bottom: isLast ? 0 : 44),
            child: Row(children: [
              Text(label,
                  style: TextStyle(
                      fontSize  : 14,
                      fontWeight: isCurrent
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: isDone
                          ? (isCurrent ? _kBlue : _kText)
                          : _kSubtext)),
              const Spacer(),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color       : _kBlueTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: _kBorder, width: 1),
                  ),
                  child: const Text('Current',
                      style: TextStyle(
                          fontSize  : 11,
                          fontWeight: FontWeight.w700,
                          color     : _kBlue)),
                )
              else if (isDone)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color       : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('Done',
                      style: TextStyle(
                          fontSize  : 11,
                          fontWeight: FontWeight.w700,
                          color     : Colors.green.shade600)),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Mark Resolved button ──────────────────────────────────────────────────────
class _MarkResolvedButton extends StatefulWidget {
  final String docId;
  const _MarkResolvedButton({required this.docId});

  @override
  State<_MarkResolvedButton> createState() => _MarkResolvedButtonState();
}

class _MarkResolvedButtonState extends State<_MarkResolvedButton> {
  bool _loading = false;

  Future<void> _resolve() async {
    setState(() => _loading = true);
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.docId)
          .update({'status': 'Resolved'});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Complaint marked as resolved',
              style: TextStyle(fontWeight: FontWeight.w500)),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width : double.infinity,
      height: 52,
      child : ElevatedButton.icon(
        onPressed: _loading ? null : _resolve,
        icon: _loading
            ? const SizedBox(
                width : 18, height: 18,
                child : CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : const Icon(Icons.check_circle_rounded, size: 20),
        label: Text(_loading ? 'Updating…' : 'Mark as Resolved',
            style: const TextStyle(
                fontSize  : 15,
                fontWeight: FontWeight.w700)),
        style: ElevatedButton.styleFrom(
          backgroundColor       : Colors.green.shade600,
          foregroundColor       : Colors.white,
          disabledBackgroundColor:
              Colors.green.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────
class _R {
  final IconData icon;
  final String   label;
  final String   value;
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
            color: _kBorder.withOpacity(0.5), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A1565C0),
              blurRadius: 10,
              offset: Offset(0, 3)),
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
                  width : 32, height: 32,
                  decoration: BoxDecoration(
                    color       : _kBlueTint,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(r.icon, color: _kBlue, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(r.label,
                      style: const TextStyle(
                          fontSize  : 13,
                          color     : _kSubtext,
                          fontWeight: FontWeight.w500)),
                ),
                Flexible(
                  child: Text(r.value,
                      textAlign: TextAlign.end,
                      overflow : TextOverflow.ellipsis,
                      style    : const TextStyle(
                          fontSize  : 13,
                          fontWeight: FontWeight.w700,
                          color     : _kText)),
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