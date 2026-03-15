import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/complaint_theme.dart';
import 'request_list_page.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class RequestComplaintPage extends StatelessWidget {
  const RequestComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [

          // ── Header ────────────────────────────────────────────────────
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
                          color        : Colors.white.withOpacity(0.18),
                          borderRadius : BorderRadius.circular(11),
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
                        Text(
                          'Requests & Complaints',
                          style: TextStyle(
                              color        : Colors.white,
                              fontSize     : 20,
                              fontWeight   : FontWeight.w800,
                              letterSpacing: -0.3),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Manage student submissions',
                          style: TextStyle(
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

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Section label
                  Row(
                    children: [
                      Container(
                        width : 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.inbox_rounded,
                            color: _kBlue, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Category',
                        style: TextStyle(
                            fontSize     : 16,
                            fontWeight   : FontWeight.w800,
                            color        : _kText,
                            letterSpacing: -0.2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _OptionCard(
                    icon    : Icons.assignment_turned_in_rounded,
                    title   : 'View Requests',
                    subtitle: 'Review and manage student requests',
                    onTap   : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RequestListPage(role: ViewerRole.warden),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _OptionCard(
                    icon    : Icons.report_problem_rounded,
                    title   : 'View Complaints',
                    subtitle: 'Forward or reject student complaints',
                    onTap   : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const WardenComplaintListPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Option Card ───────────────────────────────────────────────────────────────
class _OptionCard extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width  : double.infinity,
        padding: const EdgeInsets.all(18),
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
              width : 50,
              height: 50,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _kBlue, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 15,
                          color     : _kText)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: _kSubtext)),
                ],
              ),
            ),
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: _kBlue, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// WARDEN COMPLAINT LIST PAGE — NO CHANGES
// ================================================================
class WardenComplaintListPage extends StatefulWidget {
  const WardenComplaintListPage({super.key});

  @override
  State<WardenComplaintListPage> createState() =>
      _WardenComplaintListPageState();
}

class _WardenComplaintListPageState extends State<WardenComplaintListPage> {
  String _filter = 'All';
  String _search = '';
  String _categoryFilter = 'All Categories';
  DateTime? _selectedDate;

  final List<String> filters = [
    'All',
    'Pending',
    'Accepted',
    'Resolved',
    'Rejected',
    'Forwarded',
  ];

  final List<String> categoryFilters = [
    'All Categories',
    'Room Complaint',
    'Mess Complaint',
    'General Complaint',
    'Private Complaint',
  ];

  Color _categoryColor(String category) {
    switch (category) {
      case 'Room Complaint':
        return kComplaintBlue;
      case 'Mess Complaint':
        return const Color(0xFFE65100);
      case 'General Complaint':
        return kComplaintBlue;
      case 'Private Complaint':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _wardenAction(Map<String, dynamic> data) {
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    final entry = history.lastWhere(
      (h) => h['stage'] == 'Warden',
      orElse: () => <String, dynamic>{},
    );
    return (entry['action'] ?? '').toString();
  }

  List<String> _wardenActions(Map<String, dynamic> data) {
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    return history
        .where((h) => h['stage'] == 'Warden')
        .map((h) => (h['action'] ?? '').toString())
        .toList();
  }

  bool _isForWarden(Map<String, dynamic> data) {
    if (data['isPrivate'] == true) return true;
    final stage = (data['currentStage'] ?? '').toString();
    if (stage == 'Warden') return true;
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    if (history.any((h) => h['stage'] == 'Warden')) return true;
    if (history.any(
      (h) =>
          h['stage'] == 'RT' &&
          (h['action'] == 'forwarded' || h['action'] == 'accepted'),
    )) {
      return true;
    }
    return false;
  }

  bool _wasForwardedByRT(Map<String, dynamic> data) {
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    return history.any((h) => h['stage'] == 'RT' && h['action'] == 'forwarded');
  }

  bool _matchesFilter(Map<String, dynamic> data) {
    final action  = _wardenAction(data);
    final actions = _wardenActions(data);
    final stage   = (data['currentStage'] ?? '').toString();
    switch (_filter.trim()) {
      case 'Pending':
        return action.isEmpty && (stage == 'Warden' || _wasForwardedByRT(data));
      case 'Accepted':
        return actions.contains('accepted') &&
            !actions.contains('resolved') &&
            !actions.contains('rejected');
      case 'Resolved':
        return action == 'resolved';
      case 'Rejected':
        return action == 'rejected';
      case 'Forwarded':
        return action == 'forwarded';
      default:
        return true;
    }
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return (data['studentName'] ?? '').toString().toLowerCase().contains(q) ||
        (data['category'] ?? '').toString().toLowerCase().contains(q) ||
        (data['studentRoom'] ?? '').toString().toLowerCase().contains(q);
  }

  bool _matchesCategory(Map<String, dynamic> data) {
    if (_categoryFilter == 'All Categories') return true;
    return (data['category'] ?? '') == _categoryFilter;
  }

  DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime(2000);
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime(2000);
    try {
      return (raw as dynamic).toDate();
    } catch (_) {
      return DateTime(2000);
    }
  }

  bool _matchesDate(Map<String, dynamic> data) {
    if (_selectedDate == null) return true;
    final raw = data['createdAt'];
    if (raw == null) return false;
    DateTime dt;
    try {
      dt = (raw as dynamic).toDate();
    } catch (_) {
      if (raw is String) {
        dt = DateTime.tryParse(raw) ?? DateTime(2000);
      } else {
        return false;
      }
    }
    return dt.year == _selectedDate!.year &&
        dt.month == _selectedDate!.month &&
        dt.day == _selectedDate!.day;
  }

  Future<void> _pickFilterDate() async {
    final now    = DateTime.now();
    final picked = await showDatePicker(
      context    : context,
      initialDate: _selectedDate ?? now,
      firstDate  : DateTime(2000),
      lastDate   : DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary  : kComplaintBlue,
            onPrimary: Colors.white,
            onSurface: Color(0xFF1B1B1B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatFilterDate(DateTime d) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Widget _categoryDropdown() {
    return Container(
      width  : double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color       : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoryFilter,
          icon : const Icon(Icons.keyboard_arrow_down,
              color: kComplaintBlueLight),
          style: const TextStyle(
            color     : Color(0xFF1B1B1B),
            fontSize  : 13,
            fontWeight: FontWeight.w600,
          ),
          items: categoryFilters
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) => setState(() => _categoryFilter = v!),
        ),
      ),
    );
  }

  Widget _complaintPreview(Map<String, dynamic> data, Color bg) {
    return Container(
      width  : double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color       : bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['studentName'] ?? '',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 14)),
          Text('Room ${data['studentRoom']}  ·  ${data['category']}',
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(data['message'] ?? '',
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF444444))),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String    label,
    required IconData  icon,
    required Color     bgColor,
    required Color     textColor,
    required bool      done,
    required bool      isThis,
    required VoidCallback onTap,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: (done && !isThis) || isThis ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: done
                ? (isThis ? textColor : Colors.grey.shade200)
                : bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                done && isThis ? Icons.check_circle : icon,
                size : 15,
                color: done
                    ? (isThis ? Colors.white : Colors.grey.shade400)
                    : textColor,
              ),
              const SizedBox(width: 6),
              Text(
                done && isThis ? '$label ✓' : label,
                style: TextStyle(
                  color: done
                      ? (isThis ? Colors.white : Colors.grey.shade400)
                      : textColor,
                  fontWeight: FontWeight.w700,
                  fontSize  : 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAcceptDialog(String docId, Map<String, dynamic> data) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.thumb_up_alt_outlined, color: kComplaintBlue),
            SizedBox(width: 8),
            Text('Accept Complaint',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _complaintPreview(data, const Color(0xFFE3F2FD)),
            const SizedBox(height: 14),
            const Text('Message to Student:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 4),
            const Text(
              'Let the student know you have acknowledged their complaint.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: msgCtrl,
              maxLines  : 3,
              decoration: InputDecoration(
                hintText    : 'e.g. We will definitely fix it...',
                hintStyle   : const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide : const BorderSide(
                      color: kComplaintBlue, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final note = msgCtrl.text.trim().isNotEmpty
                  ? msgCtrl.text.trim()
                  : 'Your complaint has been accepted and is being worked on.';
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(docId)
                    .update({
                  'status'           : 'accepted',
                  'currentStage'     : 'Warden',
                  'currentStageIndex':
                      (data['chain'] as List?)?.indexOf('Warden') ?? 4,
                  'acceptMessage'    : note,
                  'wardenMessage'    : note,
                  'acceptedAt'       : DateTime.now().toIso8601String(),
                  'history'          : FieldValue.arrayUnion([
                    {
                      'stage'    : 'Warden',
                      'action'   : 'accepted',
                      'note'     : note,
                      'timestamp': DateTime.now().toIso8601String(),
                    },
                  ]),
                });
                _snack('Complaint accepted — student notified',
                    kComplaintBlue, Icons.thumb_up);
              } catch (e) {
                _snack('Error: $e', Colors.red, Icons.error);
              }
            },
            icon : const Icon(Icons.thumb_up, size: 16),
            label: const Text('Confirm Accept',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kComplaintBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showResolveDialog(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: kComplaintBlue),
            SizedBox(width: 8),
            Text('Resolve Complaint',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _complaintPreview(data, kComplaintBg),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color       : kComplaintBlueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 14, color: kComplaintBlue),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Press this only after the issue has been physically fixed.',
                      style: TextStyle(fontSize: 12, color: kComplaintBlue),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(docId)
                    .update({
                  'status'           : 'resolved',
                  'currentStage'     : 'Warden',
                  'currentStageIndex':
                      (data['chain'] as List?)?.indexOf('Warden') ?? 4,
                  'history'          : FieldValue.arrayUnion([
                    {
                      'stage'    : 'Warden',
                      'action'   : 'resolved',
                      'note'     : 'Complaint fully resolved by Warden',
                      'timestamp': DateTime.now().toIso8601String(),
                    },
                  ]),
                });
                _snack('Complaint marked as resolved',
                    kComplaintBlue, Icons.check_circle);
              } catch (e) {
                _snack('Error: $e', Colors.red, Icons.error);
              }
            },
            icon : const Icon(Icons.check_circle, size: 16),
            label: const Text('Confirm Resolve',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kComplaintBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(String docId, Map<String, dynamic> data) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: Color(0xFFDC3545)),
            SizedBox(width: 8),
            Text('Reject Complaint',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _complaintPreview(data, const Color(0xFFFFF5F5)),
            const SizedBox(height: 14),
            const Text('Reason for Rejection (optional):',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              maxLines  : 3,
              decoration: InputDecoration(
                hintText      : 'Enter reason...',
                hintStyle     : const TextStyle(
                    fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide : const BorderSide(
                      color: Color(0xFFDC3545), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final note = ctrl.text.trim().isNotEmpty
                  ? ctrl.text.trim()
                  : 'Rejected by Warden';
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(docId)
                    .update({
                  'status'           : 'rejected',
                  'currentStage'     : 'Warden',
                  'currentStageIndex':
                      (data['chain'] as List?)?.indexOf('Warden') ?? 4,
                  'rejectMessage'    : note,
                  'history'          : FieldValue.arrayUnion([
                    {
                      'stage'    : 'Warden',
                      'action'   : 'rejected',
                      'note'     : note,
                      'timestamp': DateTime.now().toIso8601String(),
                    },
                  ]),
                });
                _snack('Complaint rejected',
                    const Color(0xFFDC3545), Icons.block);
              } catch (e) {
                _snack('Error: $e', Colors.red, Icons.error);
              }
            },
            icon : const Icon(Icons.block, size: 16),
            label: const Text('Confirm Reject',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _showForwardToOfficeDialog(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.forward_to_inbox, color: kComplaintBlue),
            SizedBox(width: 8),
            Text('Forward to Office Admin',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ],
        ),
        content: _complaintPreview(data, kComplaintBg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final chain      = List<String>.from(data['chain'] ?? []);
              final officeIndex = chain.indexOf('Office Admin');
              final nextIndex  =
                  officeIndex != -1 ? officeIndex : chain.length - 1;
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(docId)
                    .update({
                  'currentStageIndex': nextIndex,
                  'currentStage'     : chain.isNotEmpty
                      ? chain[nextIndex]
                      : 'Office Admin',
                  'status'           : 'pending',
                  'history'          : FieldValue.arrayUnion([
                    {
                      'stage'    : 'Warden',
                      'action'   : 'forwarded',
                      'note'     : 'Forwarded by Warden to Office Admin',
                      'timestamp': DateTime.now().toIso8601String(),
                    },
                  ]),
                });
                _snack('Forwarded to Office Admin',
                    kComplaintBlue, Icons.check_circle);
              } catch (e) {
                _snack('Error: $e', Colors.red, Icons.error);
              }
            },
            icon : const Icon(Icons.send, size: 16),
            label: const Text('Confirm Forward',
                style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: kComplaintBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String msg, Color color, IconData icon) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(msg,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        backgroundColor: color,
        behavior       : SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kComplaintBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .snapshots(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data?.docs ?? [];
          final myDocs  = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _isForWarden(data);
          }).toList();

          final total    = myDocs.length;
          final pending  = myDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return _wardenAction(data).isEmpty;
          }).length;
          final accepted = myDocs.where((d) {
            final actions = _wardenActions(d.data() as Map<String, dynamic>);
            return actions.contains('accepted') &&
                !actions.contains('resolved') &&
                !actions.contains('rejected');
          }).length;
          final resolved = myDocs.where((d) {
            return _wardenAction(d.data() as Map<String, dynamic>) ==
                'resolved';
          }).length;
          final rejected = myDocs.where((d) {
            return _wardenAction(d.data() as Map<String, dynamic>) ==
                'rejected';
          }).length;
          final forwarded = myDocs.where((d) {
            return _wardenAction(d.data() as Map<String, dynamic>) ==
                'forwarded';
          }).length;

          return Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kComplaintBlue, kComplaintBlueLight],
                    begin : Alignment.topLeft,
                    end   : Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft : Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                padding: EdgeInsets.only(
                  top   : MediaQuery.of(context).padding.top + 16,
                  left  : 20,
                  right : 20,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color        : Colors.white.withOpacity(0.2),
                              borderRadius : BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Complaints',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 22,
                                fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('Warden · Review & Manage',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _statBox('Total', total,
                              Colors.white.withOpacity(0.25)),
                          const SizedBox(width: 6),
                          _statBox('Pending', pending,
                              const Color(0xFFFFC107).withOpacity(0.6)),
                          const SizedBox(width: 6),
                          _statBox('Accepted', accepted,
                              kComplaintBlue.withOpacity(0.7)),
                          const SizedBox(width: 6),
                          _statBox('Resolved', resolved,
                              const Color(0xFF1565C0).withOpacity(0.6)),
                          const SizedBox(width: 6),
                          _statBox('Rejected', rejected,
                              const Color(0xFFDC3545).withOpacity(0.6)),
                          const SizedBox(width: 6),
                          _statBox('Fwd', forwarded,
                              const Color(0xFF6A0DAD).withOpacity(0.7)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      // Search
                      Container(
                        decoration: BoxDecoration(
                          color       : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color    : Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.search,
                                color: kComplaintBlueLight, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText : 'Search by student, room, category...',
                                  border   : InputBorder.none,
                                  hintStyle: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                                style    : const TextStyle(fontSize: 14),
                                onChanged: (v) =>
                                    setState(() => _search = v),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Date filter
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickFilterDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: _selectedDate == null
                                      ? Colors.white
                                      : kComplaintBlueTint,
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _selectedDate == null
                                        ? Colors.transparent
                                        : kComplaintBlue,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.06),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_month,
                                        size: 18, color: kComplaintBlue),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Filter by date'
                                            : _formatFilterDate(
                                                _selectedDate!),
                                        style: TextStyle(
                                          fontSize  : 13,
                                          fontWeight: _selectedDate == null
                                              ? FontWeight.normal
                                              : FontWeight.w700,
                                          color: _selectedDate == null
                                              ? Colors.grey
                                              : const Color(0xFF1B1B1B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (_selectedDate != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDate = null),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color       : const Color(0xFFFDEDEE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.close,
                                    size : 16,
                                    color: Color(0xFFDC3545)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      _categoryDropdown(),
                      const SizedBox(height: 10),

                      // Status filter tabs
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount     : filters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f      = filters[i];
                            final active = _filter == f;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _filter = f),
                              child: AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 7),
                                decoration: BoxDecoration(
                                  color: active
                                      ? kComplaintBlue
                                      : Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: active
                                          ? const Color(0xFF1565C0)
                                              .withOpacity(0.35)
                                          : Colors.black
                                              .withOpacity(0.07),
                                      blurRadius:
                                          active ? 10 : 6,
                                      offset:
                                          const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: active
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_selectedDate != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          width  : double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color       : kComplaintBlueTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.filter_list,
                                  size : 14,
                                  color: kComplaintBlue),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Showing complaints for: '
                                  '${_formatFilterDate(_selectedDate!)}',
                                  style: const TextStyle(
                                    fontSize  : 12,
                                    color     : kComplaintBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      Expanded(
                        child: snapshot.connectionState ==
                                ConnectionState.waiting
                            ? const Center(
                                child: CircularProgressIndicator(
                                    color: kComplaintBlue))
                            : Builder(builder: (_) {
                                final filtered =
                                    <QueryDocumentSnapshot>[];
                                for (final doc in myDocs) {
                                  try {
                                    final data = doc.data()
                                        as Map<String, dynamic>;
                                    if (_matchesFilter(data) &&
                                        _matchesSearch(data) &&
                                        _matchesCategory(data) &&
                                        _matchesDate(data)) {
                                      filtered.add(doc);
                                    }
                                  } catch (_) {}
                                }
                                filtered.sort((a, b) {
                                  try {
                                    return _parseDate(
                                      (b.data()
                                          as Map)['createdAt'],
                                    ).compareTo(
                                      _parseDate(
                                        (a.data()
                                            as Map)['createdAt'],
                                      ),
                                    );
                                  } catch (_) {
                                    return 0;
                                  }
                                });

                                if (filtered.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inbox_outlined,
                                            size : 60,
                                            color: Colors
                                                .grey.shade300),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No complaints found.',
                                          style: TextStyle(
                                              color  : Colors.grey,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount  : filtered.length,
                                  itemBuilder: (_, index) {
                                    final doc  = filtered[index];
                                    final data = doc.data()
                                        as Map<String, dynamic>;
                                    final docId = doc.id;

                                    final wardenAction =
                                        _wardenAction(data);
                                    final wardenActions =
                                        _wardenActions(data);
                                    final isAccepted =
                                        wardenActions.contains(
                                            'accepted') &&
                                        !wardenActions.contains(
                                            'resolved') &&
                                        !wardenActions
                                            .contains('rejected');
                                    final isResolved =
                                        wardenAction == 'resolved';
                                    final isRejected =
                                        wardenAction == 'rejected';
                                    final isForwarded =
                                        wardenAction == 'forwarded';
                                    final actionDone = isResolved ||
                                        isRejected ||
                                        isForwarded;
                                    final fromRT =
                                        _wasForwardedByRT(data);
                                    final isPrivate =
                                        data['isPrivate'] == true;

                                    return Container(
                                      margin: const EdgeInsets.only(
                                          bottom: 14),
                                      decoration: BoxDecoration(
                                        color       : Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withOpacity(0.07),
                                            blurRadius: 12,
                                            offset:
                                                const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.all(
                                                    14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data['studentName'] ??
                                                              'Unknown',
                                                          style: const TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w800,
                                                            fontSize:
                                                                15,
                                                            color: Color(
                                                                0xFF1B1B1B),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 2),
                                                        Text(
                                                          'Room ${data['studentRoom'] ?? '-'}',
                                                          style: const TextStyle(
                                                            fontSize:
                                                                12,
                                                            color: Colors
                                                                .grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical  : 4,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: isRejected
                                                            ? const Color(
                                                                0xFFFDEDEE)
                                                            : isResolved
                                                            ? const Color(
                                                                0xFFE8F0FE)
                                                            : isAccepted
                                                            ? const Color(
                                                                0xFFE3F2FD)
                                                            : isForwarded
                                                            ? const Color(
                                                                0xFFE8F0FE)
                                                            : const Color(
                                                                0xFFFFF3CD),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize
                                                                .min,
                                                        children: [
                                                          Container(
                                                            width : 7,
                                                            height: 7,
                                                            decoration:
                                                                BoxDecoration(
                                                              color: isRejected
                                                                  ? const Color(0xFFDC3545)
                                                                  : isResolved
                                                                  ? const Color(0xFF1565C0)
                                                                  : isAccepted
                                                                  ? const Color(0xFF1565C0)
                                                                  : isForwarded
                                                                  ? const Color(0xFF6A0DAD)
                                                                  : const Color(0xFFFFC107),
                                                              shape:
                                                                  BoxShape
                                                                      .circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Text(
                                                            isRejected
                                                                ? 'Rejected'
                                                                : isResolved
                                                                ? 'Resolved'
                                                                : isAccepted
                                                                ? 'Accepted'
                                                                : isForwarded
                                                                ? 'Forwarded'
                                                                : 'Pending',
                                                            style: TextStyle(
                                                              color: isRejected
                                                                  ? const Color(0xFF8B0000)
                                                                  : isResolved
                                                                  ? const Color(0xFF155724)
                                                                  : isAccepted
                                                                  ? const Color(0xFF0D47A1)
                                                                  : isForwarded
                                                                  ? const Color(0xFF4A0080)
                                                                  : const Color(0xFF856404),
                                                              fontSize  : 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                    height: 10),

                                                if (isPrivate)
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .only(bottom: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical  : 3,
                                                    ),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: Colors
                                                          .purple.shade50,
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  8),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize
                                                              .min,
                                                      children: [
                                                        Icon(Icons.lock,
                                                            size : 12,
                                                            color: Colors
                                                                .purple),
                                                        SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'Private Complaint',
                                                          style: TextStyle(
                                                            fontSize  : 11,
                                                            color     : Colors.purple,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                if (fromRT && !isPrivate)
                                                  Container(
                                                    margin: const EdgeInsets
                                                        .only(bottom: 8),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical  : 3,
                                                    ),
                                                    decoration:
                                                        BoxDecoration(
                                                      color: const Color(
                                                          0xFFE8F0FE),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                                  8),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize
                                                              .min,
                                                      children: [
                                                        Icon(
                                                          Icons.forward_to_inbox,
                                                          size : 12,
                                                          color: Color(0xFF1565C0),
                                                        ),
                                                        SizedBox(
                                                            width: 4),
                                                        Text(
                                                          'Forwarded by RT',
                                                          style: TextStyle(
                                                            fontSize  : 11,
                                                            color     : Color(0xFF1565C0),
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),

                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical  : 4,
                                                      ),
                                                      decoration:
                                                          BoxDecoration(
                                                        color: _categoryColor(
                                                          data['category'] ??
                                                              '',
                                                        ).withOpacity(
                                                            0.12),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    20),
                                                      ),
                                                      child: Text(
                                                        data['category'] ??
                                                            '',
                                                        style: TextStyle(
                                                          color: _categoryColor(
                                                            data['category'] ??
                                                                '',
                                                          ),
                                                          fontSize  : 11,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                        width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        data['message'] ??
                                                            '',
                                                        style: const TextStyle(
                                                          fontSize: 13,
                                                          color   : Color(
                                                              0xFF555555),
                                                        ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                if (isAccepted) ...[
                                                  const SizedBox(
                                                      height: 8),
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.thumb_up,
                                                        size : 13,
                                                        color: Color(
                                                            0xFF1565C0),
                                                      ),
                                                      const SizedBox(
                                                          width: 4),
                                                      const Text(
                                                        'Accepted — ',
                                                        style: TextStyle(
                                                          fontSize  : 12,
                                                          color     : Color(0xFF1565C0),
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Text(
                                                          data['acceptMessage'] ??
                                                              'Being worked on',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color   : Color(0xFF1565C0),
                                                          ),
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (isResolved) ...[
                                                  const SizedBox(
                                                      height: 8),
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        size : 13,
                                                        color: Color(0xFF1565C0),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Resolved by Warden',
                                                        style: TextStyle(
                                                          fontSize  : 12,
                                                          color     : Color(0xFF1565C0),
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (isForwarded) ...[
                                                  const SizedBox(
                                                      height: 8),
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.forward_to_inbox,
                                                        size : 13,
                                                        color: Color(0xFF6A0DAD),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Forwarded to: Office Admin',
                                                        style: TextStyle(
                                                          fontSize  : 12,
                                                          color     : Color(0xFF6A0DAD),
                                                          fontWeight: FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),

                                          Container(
                                            decoration:
                                                const BoxDecoration(
                                              color: Color(0xFFF8FFFE),
                                              border: Border(
                                                top: BorderSide(
                                                  color: Color(
                                                      0xFFE8F0EC),
                                                ),
                                              ),
                                              borderRadius:
                                                  BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(18),
                                                bottomRight:
                                                    Radius.circular(18),
                                              ),
                                            ),
                                            padding: const EdgeInsets
                                                .symmetric(
                                              horizontal: 14,
                                              vertical  : 10,
                                            ),
                                            child: Column(
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                if (!isAccepted &&
                                                    !actionDone)
                                                  Column(
                                                    children: [
                                                      Row(children: [
                                                        _actionBtn(
                                                          label    : 'Accept',
                                                          icon     : Icons.thumb_up_alt_outlined,
                                                          bgColor  : const Color(0xFFE3F2FD),
                                                          textColor: const Color(0xFF1565C0),
                                                          done     : false,
                                                          isThis   : false,
                                                          onTap    : () => _showAcceptDialog(docId, data),
                                                        ),
                                                        const SizedBox(width: 10),
                                                        _actionBtn(
                                                          label    : 'Reject',
                                                          icon     : Icons.cancel_outlined,
                                                          bgColor  : const Color(0xFFFDEDEE),
                                                          textColor: const Color(0xFFDC3545),
                                                          done     : false,
                                                          isThis   : false,
                                                          onTap    : () => _showRejectDialog(docId, data),
                                                        ),
                                                      ]),
                                                      if (!isPrivate) ...[
                                                        const SizedBox(height: 8),
                                                        GestureDetector(
                                                          onTap: () => _showForwardToOfficeDialog(docId, data),
                                                          child: Container(
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                                            decoration: BoxDecoration(
                                                              color       : const Color(0xFFE3F2FD),
                                                              borderRadius: BorderRadius.circular(12),
                                                            ),
                                                            child: const Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Icon(Icons.forward_to_inbox, size: 15, color: Color(0xFF1565C0)),
                                                                SizedBox(width: 6),
                                                                Text('Forward to Office Admin',
                                                                    style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w700, fontSize: 13)),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),

                                                if (isAccepted)
                                                  Row(children: [
                                                    _actionBtn(
                                                      label    : 'Resolve',
                                                      icon     : Icons.check_circle_outline,
                                                      bgColor  : const Color(0xFFE8F0FE),
                                                      textColor: const Color(0xFF1565C0),
                                                      done     : false,
                                                      isThis   : false,
                                                      onTap    : () => _showResolveDialog(docId, data),
                                                    ),
                                                    const SizedBox(width: 10),
                                                    _actionBtn(
                                                      label    : 'Reject',
                                                      icon     : Icons.cancel_outlined,
                                                      bgColor  : const Color(0xFFFDEDEE),
                                                      textColor: const Color(0xFFDC3545),
                                                      done     : false,
                                                      isThis   : false,
                                                      onTap    : () => _showRejectDialog(docId, data),
                                                    ),
                                                  ]),

                                                if (isResolved)
                                                  Row(children: [
                                                    _actionBtn(
                                                      label    : 'Resolved',
                                                      icon     : Icons.check_circle,
                                                      bgColor  : const Color(0xFF1565C0),
                                                      textColor: Colors.white,
                                                      done     : true,
                                                      isThis   : true,
                                                      onTap    : () {},
                                                    ),
                                                  ]),
                                                if (isRejected)
                                                  Row(children: [
                                                    _actionBtn(
                                                      label    : 'Rejected',
                                                      icon     : Icons.block,
                                                      bgColor  : const Color(0xFFDC3545),
                                                      textColor: Colors.white,
                                                      done     : true,
                                                      isThis   : true,
                                                      onTap    : () {},
                                                    ),
                                                  ]),
                                                if (isForwarded)
                                                  Row(children: [
                                                    _actionBtn(
                                                      label    : 'Forwarded to Office Admin',
                                                      icon     : Icons.forward_to_inbox,
                                                      bgColor  : const Color(0xFF6A0DAD),
                                                      textColor: Colors.white,
                                                      done     : true,
                                                      isThis   : true,
                                                      onTap    : () {},
                                                    ),
                                                  ]),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }),
                      ),
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

  Widget _statBox(String label, int count, Color color) {
    return Container(
      width  : 72,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color       : color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text('$count',
              style: const TextStyle(
                  color     : Colors.white,
                  fontSize  : 20,
                  fontWeight: FontWeight.w800)),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }
}