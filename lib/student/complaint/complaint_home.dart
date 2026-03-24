import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/complaint_theme.dart';
import '../student_data.dart';

/// ===============================
/// CONSTANTS
/// ===============================
const Map<String, List<String>> kComplaintChain = {
  'Room Complaint': [
    'Submitted',
    'Hostel Secretary',
    'Matron',
    'RT',
    'Warden',
    'Office Admin',
  ],
  'Mess Complaint': [
    'Submitted',
    'Mess Secretary',
    'Matron',
    'RT',
    'Warden',
    'Office Admin',
  ],
  'General Complaint': [
    'Submitted',
    'Hostel Secretary',
    'Matron',
    'RT',
    'Warden',
    'Office Admin',
  ],
  'Private Complaint': ['Submitted', 'Warden'],
};

/// ===============================
/// COMPLAINT HOME
/// ===============================
class ComplaintHome extends StatelessWidget {
  const ComplaintHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kComplaintBg,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kComplaintBlue, kComplaintBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 28,
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Complaints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Raise or track your complaints',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _OptionCard(
                    icon: Icons.edit_note_rounded,
                    title: 'Raise Complaint',
                    subtitle: 'Submit a new room, mess or general complaint',
                    color: kComplaintBlue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ComplaintForm()),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _OptionCard(
                    icon: Icons.manage_search_rounded,
                    title: 'My Complaints',
                    subtitle: 'Track the status of your submitted complaints',
                    color: kComplaintBlue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyComplaints()),
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

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Color(0xFF1B1B1B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// COMPLAINT FORM
/// ===============================
class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final _messageCtrl = TextEditingController();
  String _category = 'Room Complaint';
  bool _submitting = false;
  DateTime? _incidentDate;
  TimeOfDay? _incidentTime;

  final List<String> _categories = [
    'Room Complaint',
    'Mess Complaint',
    'General Complaint',
    'Private Complaint',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _incidentDate = now;
    _incidentTime = TimeOfDay(hour: now.hour, minute: now.minute);
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _submit() async {
    if (_messageCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please describe your problem")),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      final chain = kComplaintChain[_category]!;
      final isPrivate = _category == 'Private Complaint';
      await FirebaseFirestore.instance.collection('complaints').add({
        'category': _category,
        'message': _messageCtrl.text.trim(),
        'studentName': StudentData.name,
        'studentRoom': StudentData.room,
        'studentId': StudentData.admissionNo,
        'isPrivate': isPrivate,
        'chain': chain,
        // Start at index 1 — skip 'Submitted' so complaint lands immediately
        // at the first authority's inbox (Hostel Secretary / Mess Secretary / Warden)
        'currentStageIndex': 1,
        'currentStage': chain[1],
        'status': 'pending',
        'history': [],
        'incidentDate': _formatDate(_incidentDate!),
        'incidentTime': _formatTime(_incidentTime!),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: kComplaintBlue),
              const SizedBox(width: 8),
              const Text(
                'Submitted!',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Text(
            isPrivate
                ? "Your private message has been sent to the Warden."
                : "Your complaint has been submitted successfully.",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kComplaintBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'OK',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = _category == 'Private Complaint';
    return Scaffold(
      backgroundColor: kComplaintBg,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kComplaintBlue, kComplaintBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
              bottom: 24,
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Raise Complaint',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Category dropdown
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Complaint Category',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _category,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: kComplaintBlueLight,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF1B1B1B),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem<String>(
                                    value: c,
                                    child: Row(
                                      children: [
                                        if (c == 'Private Complaint') ...[
                                          const Icon(
                                            Icons.lock,
                                            color: Colors.purple,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                        ],
                                        Text(c),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Info banner
                  if (isPrivate)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.amber.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "This message goes directly and only to the Warden. No one else can see it.",
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (!isPrivate)
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: kComplaintBlueTint,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kComplaintBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.alt_route,
                                size: 16,
                                color: kComplaintBlue,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Forwarding Chain',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  color: kComplaintBlue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            kComplaintChain[_category]!.join('  →  '),
                            style: const TextStyle(
                              fontSize: 12,
                              color: kComplaintBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Student info (read-only)
                  _FormCard(
                    child: Column(
                      children: [
                        _ReadOnlyRow(
                          icon: Icons.person,
                          label: 'Name',
                          value: StudentData.name,
                        ),
                        const Divider(height: 16),
                        _ReadOnlyRow(
                          icon: Icons.meeting_room,
                          label: 'Room',
                          value: StudentData.room,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Incident date/time
                  _FormCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_note,
                          size: 18,
                          color: kComplaintBlue,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Incident Date & Time',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _incidentDate != null && _incidentTime != null
                                  ? '${_formatDate(_incidentDate!)}   ·   ${_formatTime(_incidentTime!)}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Message
                  _FormCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPrivate
                              ? 'Private Message to Warden'
                              : 'Describe Your Problem',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _messageCtrl,
                          maxLines: 5,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Write your complaint here...',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kComplaintBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _submitting ? null : _submit,
                      child: _submitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isPrivate ? 'Send to Warden' : 'Submit Complaint',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final Widget child;
  const _FormCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: child,
    );
  }
}

class _ReadOnlyRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ReadOnlyRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: kComplaintBlue),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ===============================
/// MY COMPLAINTS
/// ===============================
class MyComplaints extends StatelessWidget {
  const MyComplaints({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kComplaintBg,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [kComplaintBlue, kComplaintBlueLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 20,
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
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'My Complaints',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Track all your submitted complaints',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('complaints')
                  .where('studentId', isEqualTo: StudentData.admissionNo)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kComplaintBlue),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No complaints yet',
                          style: TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Tap "Raise Complaint" to submit one',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }
                final docs = snapshot.data!.docs.toList()
                  ..sort((a, b) {
                    final aT = (a.data() as Map)['createdAt'];
                    final bT = (b.data() as Map)['createdAt'];
                    if (aT == null || bT == null) return 0;
                    return (bT as Timestamp).compareTo(aT as Timestamp);
                  });
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc = docs[i];
                    final data = doc.data() as Map<String, dynamic>;
                    return _ComplaintCard(id: doc.id, data: data);
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

/// ===============================
/// COMPLAINT CARD — redesigned
/// ===============================
class _ComplaintCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  const _ComplaintCard({required this.id, required this.data});

  Color _statusBg(String s) {
    switch (s) {
      case 'accepted':
        return const Color(0xFFE3F2FD);
      case 'resolved':
        return const Color(0xFFD4EDDA);
      case 'rejected':
        return const Color(0xFFFDEDEE);
      default:
        return const Color(0xFFFFF3CD);
    }
  }

  Color _statusDot(String s) {
    switch (s) {
      case 'accepted':
        return kComplaintBlue;
      case 'resolved':
        return const Color(0xFF28A745);
      case 'rejected':
        return const Color(0xFFDC3545);
      default:
        return const Color(0xFFFFC107);
    }
  }

  Color _statusText(String s) {
    switch (s) {
      case 'accepted':
        return const Color(0xFF0D47A1);
      case 'resolved':
        return const Color(0xFF155724);
      case 'rejected':
        return const Color(0xFF8B0000);
      default:
        return const Color(0xFF856404);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted':
        return 'Accepted';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  Color _categoryColor(String c) {
    switch (c) {
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

  @override
  Widget build(BuildContext context) {
    final status = data['status'] ?? 'pending';
    final category = data['category'] ?? '';
    final message = data['message'] ?? '';
    final currentStage = data['currentStage'] ?? '';
    final isPrivate = data['isPrivate'] == true;
    final incidentDate = data['incidentDate'] as String?;
    final incidentTime = data['incidentTime'] as String?;

    // Authority message: pick best available
    final authorityMsg =
        (data['rejectMessage'] ??
                data['resolveMessage'] ??
                data['officeAdminMessage'] ??
                data['wardenMessage'] ??
                data['acceptMessage'])
            as String?;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ComplaintTrackingPage(complaintId: id, data: data),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + status badge row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isPrivate
                                ? Icons.lock
                                : Icons.report_problem_outlined,
                            size: 16,
                            color: _categoryColor(category),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            category,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: _categoryColor(category),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg(status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _statusDot(status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _statusLabel(status),
                              style: TextStyle(
                                color: _statusText(status),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Message
                  Text(
                    message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF555555),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Incident date/time
                  if (incidentDate != null || incidentTime != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 13,
                          color: kComplaintBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          [
                            if (incidentDate != null) incidentDate,
                            if (incidentTime != null) incidentTime,
                          ].join('  ·  '),
                          style: const TextStyle(
                            fontSize: 12,
                            color: kComplaintBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),

                  // Current stage
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stage: $currentStage',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // Authority message banner
                  if (authorityMsg != null && authorityMsg.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: status == 'resolved'
                            ? const Color(0xFFD4EDDA)
                            : status == 'rejected'
                            ? const Color(0xFFFDEDEE)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            status == 'resolved'
                                ? Icons.check_circle
                                : status == 'rejected'
                                ? Icons.block
                                : Icons.message_outlined,
                            size: 14,
                            color: _statusDot(status),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              authorityMsg,
                              style: TextStyle(
                                fontSize: 12,
                                color: _statusText(status),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Bottom bar
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FFFE),
                border: Border(top: BorderSide(color: Color(0xFFE8F0EC))),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontSize: 13,
                      color: kComplaintBlue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 13,
                    color: kComplaintBlue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===============================
/// COMPLAINT TRACKING PAGE
/// ===============================
class ComplaintTrackingPage extends StatefulWidget {
  final String complaintId;
  final Map<String, dynamic> data;
  const ComplaintTrackingPage({
    super.key,
    required this.complaintId,
    required this.data,
  });

  @override
  State<ComplaintTrackingPage> createState() => _ComplaintTrackingPageState();
}

class _ComplaintTrackingPageState extends State<ComplaintTrackingPage> {
  bool _forwarding = false;

  Future<void> _forwardComplaint(
    Map<String, dynamic> d,
    List<String> chain,
    int currentIndex,
  ) async {
    final nextIndex = currentIndex + 1;
    if (nextIndex >= chain.length) return;
    setState(() => _forwarding = true);
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(widget.complaintId)
          .update({
            'currentStageIndex': nextIndex,
            'currentStage': chain[nextIndex],
            'history': FieldValue.arrayUnion([
              {
                'stage': chain[currentIndex],
                'action': 'forwarded',
                'note': 'Forwarded by student to ${chain[nextIndex]}',
                'timestamp': DateTime.now().toIso8601String(),
              },
            ]),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Forwarded to ${chain[nextIndex]}"),
          backgroundColor: kComplaintBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _forwarding = false);
    }
  }

  void _showForwardConfirmation(
    Map<String, dynamic> d,
    List<String> chain,
    int currentIndex,
  ) {
    final next = chain[currentIndex + 1];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.forward, color: kComplaintBlue),
            SizedBox(width: 8),
            Text(
              'Forward Complaint',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Text("Forward this complaint to $next?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: kComplaintBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _forwardComplaint(d, chain, currentIndex);
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text(
              'Forward',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // helpers
  Color _statusBg(String s) {
    switch (s) {
      case 'accepted':
        return const Color(0xFFE3F2FD);
      case 'resolved':
        return const Color(0xFFD4EDDA);
      case 'rejected':
        return const Color(0xFFFDEDEE);
      default:
        return const Color(0xFFFFF3CD);
    }
  }

  Color _statusDot(String s) {
    switch (s) {
      case 'accepted':
        return kComplaintBlue;
      case 'resolved':
        return const Color(0xFF28A745);
      case 'rejected':
        return const Color(0xFFDC3545);
      default:
        return const Color(0xFFFFC107);
    }
  }

  Color _statusTextColor(String s) {
    switch (s) {
      case 'accepted':
        return const Color(0xFF0D47A1);
      case 'resolved':
        return const Color(0xFF155724);
      case 'rejected':
        return const Color(0xFF8B0000);
      default:
        return const Color(0xFF856404);
    }
  }

  String _statusLabel(String s) {
    switch (s) {
      case 'accepted':
        return 'Accepted';
      case 'resolved':
        return 'Resolved';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Pending';
    }
  }

  IconData _statusIcon(String s) {
    switch (s) {
      case 'accepted':
        return Icons.thumb_up_alt;
      case 'resolved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kComplaintBg,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .doc(widget.complaintId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: kComplaintBlue),
            );
          }

          final d = snapshot.data!.data() as Map<String, dynamic>;
          final chain = List<String>.from(d['chain'] ?? []);
          final currentIndex = d['currentStageIndex'] ?? 0;
          final history = List<Map<String, dynamic>>.from(d['history'] ?? []);
          final isPrivate = d['isPrivate'] == true;
          final status = d['status'] ?? 'pending';
          final incidentDate = d['incidentDate'] as String?;
          final incidentTime = d['incidentTime'] as String?;
          final canForward =
              currentIndex < chain.length - 1 && status == 'pending';

          final authorityMsg =
              (d['rejectMessage'] ??
                      d['resolveMessage'] ??
                      d['officeAdminMessage'] ??
                      d['wardenMessage'] ??
                      d['acceptMessage'])
                  as String?;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kComplaintBlue, kComplaintBlueLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 20,
                    right: 20,
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
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Complaint Details',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Status chip in header
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _statusIcon(status),
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _statusLabel(status),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Authority message banner ──
                    if (authorityMsg != null && authorityMsg.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _statusBg(status),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _statusDot(status).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  status == 'resolved'
                                      ? Icons.check_circle
                                      : status == 'rejected'
                                      ? Icons.block
                                      : Icons.message_outlined,
                                  color: _statusDot(status),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  status == 'resolved'
                                      ? 'Issue Resolved'
                                      : status == 'rejected'
                                      ? 'Complaint Rejected'
                                      : 'Message from Authority',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: _statusTextColor(status),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              authorityMsg,
                              style: TextStyle(
                                fontSize: 14,
                                color: _statusTextColor(status),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // ── Complaint info ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPrivate) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Colors.purple.shade700,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Private Complaint',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          Row(
                            children: [
                              const Icon(
                                Icons.category_outlined,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                d['category'] ?? '',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.meeting_room_outlined,
                                size: 15,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Room ${d['studentRoom'] ?? '-'}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          if (incidentDate != null || incidentTime != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: kComplaintBlueTint,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFF1565C0,
                                  ).withOpacity(0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.event_note,
                                    size: 16,
                                    color: kComplaintBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Incident Date & Time',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: kComplaintBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        [
                                          if (incidentDate != null)
                                            incidentDate,
                                          if (incidentTime != null)
                                            incidentTime,
                                        ].join('   ·   '),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1B1B1B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          const Text(
                            'Complaint Message',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            d['message'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Status tracker ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Tracker',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B1B1B),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Builder(
                            builder: (context) {
                              // If resolved/accepted/rejected, find the stage
                              // from history (not currentStageIndex which may be stale)
                              // Derive which stage resolved/accepted/rejected
                              // from history — more reliable than currentStageIndex
                              // which may be stale for older complaints
                              int displayIndex = currentIndex;
                              if (status == 'resolved' ||
                                  status == 'accepted' ||
                                  status == 'rejected') {
                                // First try: find exact action match in history
                                Map<String, dynamic> actionEntry = history
                                    .lastWhere(
                                      (h) => h['action'] == status,
                                      orElse: () => <String, dynamic>{},
                                    );
                                // Fallback: find any terminal action (resolved/accepted/rejected)
                                if (actionEntry.isEmpty) {
                                  actionEntry = history.lastWhere(
                                    (h) =>
                                        h['action'] == 'resolved' ||
                                        h['action'] == 'accepted' ||
                                        h['action'] == 'rejected',
                                    orElse: () => <String, dynamic>{},
                                  );
                                }
                                final actionStage =
                                    actionEntry['stage'] as String?;
                                if (actionStage != null &&
                                    chain.contains(actionStage)) {
                                  final historyIndex = chain.indexOf(
                                    actionStage,
                                  );
                                  // Only use history index if it makes sense
                                  // (should be >= currentIndex or overrides stale index)
                                  displayIndex = historyIndex;
                                }
                              }
                              return Column(
                                children: List.generate(
                                  chain.length,
                                  (i) => _TrackStep(
                                    label: chain[i],
                                    isDone: i < displayIndex,
                                    isCurrent: i == displayIndex,
                                    isLast: i == chain.length - 1,
                                    status: status,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── History ──
                    if (history.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Action History',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1B1B1B),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...history.map((h) => _HistoryTile(entry: h)),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ===============================
/// TRACK STEP
/// ===============================
class _TrackStep extends StatelessWidget {
  final String label;
  final bool isDone;
  final bool isCurrent;
  final bool isLast;
  final String status;

  const _TrackStep({
    required this.label,
    required this.isDone,
    required this.isCurrent,
    required this.isLast,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color dot() {
      if (isDone) return const Color(0xFF28A745);
      if (isCurrent) {
        if (status == 'resolved') return const Color(0xFF28A745);
        if (status == 'rejected') return const Color(0xFFDC3545);
        if (status == 'accepted') return kComplaintBlue;
        return const Color(0xFFFFC107);
      }
      return Colors.grey.shade300;
    }

    IconData icon() {
      if (isDone) return Icons.check_circle;
      if (isCurrent) {
        if (status == 'resolved') return Icons.check_circle;
        if (status == 'rejected') return Icons.cancel;
        if (status == 'accepted') return Icons.thumb_up_alt;
        return Icons.radio_button_checked;
      }
      return Icons.radio_button_unchecked;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon(), color: dot(), size: 22),
            if (!isLast)
              Container(
                width: 2,
                height: 26,
                color: isDone ? const Color(0xFF28A745) : Colors.grey.shade200,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            child: Row(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.normal,
                    color: isCurrent ? const Color(0xFF1B1B1B) : Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'resolved'
                          ? const Color(0xFFD4EDDA)
                          : status == 'rejected'
                          ? const Color(0xFFFDEDEE)
                          : status == 'accepted'
                          ? const Color(0xFFE3F2FD)
                          : const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      status == 'resolved'
                          ? 'Resolved'
                          : status == 'rejected'
                          ? 'Rejected'
                          : status == 'accepted'
                          ? 'Accepted'
                          : 'Current',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: status == 'resolved'
                            ? const Color(0xFF155724)
                            : status == 'rejected'
                            ? const Color(0xFF8B0000)
                            : status == 'accepted'
                            ? const Color(0xFF0D47A1)
                            : const Color(0xFF856404),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// ===============================
/// HISTORY TILE
/// ===============================
class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> entry;
  const _HistoryTile({required this.entry});

  Color _bg(String a) {
    switch (a) {
      case 'accepted':
        return const Color(0xFFE3F2FD);
      case 'resolved':
        return const Color(0xFFD4EDDA);
      case 'rejected':
        return const Color(0xFFFDEDEE);
      case 'forwarded':
        return const Color(0xFFEDE7F6);
      default:
        return kComplaintBg;
    }
  }

  Color _ic(String a) {
    switch (a) {
      case 'accepted':
        return kComplaintBlue;
      case 'resolved':
        return const Color(0xFF28A745);
      case 'rejected':
        return const Color(0xFFDC3545);
      case 'forwarded':
        return const Color(0xFF6F42C1);
      default:
        return Colors.grey;
    }
  }

  IconData _icon(String a) {
    switch (a) {
      case 'accepted':
        return Icons.thumb_up_alt_outlined;
      case 'resolved':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'forwarded':
        return Icons.forward_to_inbox;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final action = entry['action'] ?? '';
    final stage = entry['stage'] ?? '';
    final note = entry['note'] ?? '';
    final timestamp = entry['timestamp'] as String?;
    String? time;
    if (timestamp != null) {
      try {
        final dt = DateTime.parse(timestamp);
        const m = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        time = '${dt.day} ${m[dt.month - 1]} ${dt.year}';
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg(action),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(action), color: _ic(action), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ AFTER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        '$stage  →  ${action.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _ic(action),
                        ),
                      ),
                    ),
                    if (time != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
                if (note.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    note,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF444444),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
