import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/complaint_theme.dart';

class RtComplaintListPage extends StatefulWidget {
  const RtComplaintListPage({super.key});

  @override
  State<RtComplaintListPage> createState() => _RtComplaintListPageState();
}

class _RtComplaintListPageState extends State<RtComplaintListPage> {
  String _filter = 'All';
  String _search = '';
  String _categoryFilter = 'All Categories';
  DateTime? _selectedDate;

  final List<String> filters = ['All', 'Pending', 'Forwarded', 'Rejected'];

  final List<String> categoryFilters = [
    'All Categories',
    'Room Complaint',
    'Mess Complaint',
    'General Complaint',
  ];

  Color _categoryColor(String category) {
    switch (category) {
      case 'Room Complaint':
        return kComplaintBlue;
      case 'Mess Complaint':
        return const Color(0xFFE65100);
      case 'General Complaint':
        return kComplaintBlue;
      default:
        return Colors.grey;
    }
  }

  String _rtAction(Map<String, dynamic> data) {
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    final entry = history.lastWhere(
      (h) => h['stage'] == 'RT',
      orElse: () => {},
    );
    return (entry['action'] ?? '').toString();
  }

  bool _isForRT(Map<String, dynamic> data) {
    if (data['isPrivate'] == true) return false;
    final stage = (data['currentStage'] ?? '').toString();
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    final rtInHistory = history.any((h) => h['stage'] == 'RT');
    return stage == 'RT' || rtInHistory;
  }

  bool _matchesFilter(Map<String, dynamic> data) {
    final action = _rtAction(data);
    final stage = (data['currentStage'] ?? '').toString();
    switch (_filter) {
      case 'Pending':
        return stage == 'RT' && action.isEmpty;
      case 'Forwarded':
        return action == 'forwarded';
      case 'Rejected':
        return action == 'rejected';
      default:
        return true;
    }
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return (data['studentName'] ?? '').toLowerCase().contains(q) ||
        (data['category'] ?? '').toLowerCase().contains(q) ||
        (data['studentRoom'] ?? '').toLowerCase().contains(q);
  }

  bool _matchesCategory(Map<String, dynamic> data) {
    if (_categoryFilter == 'All Categories') return true;
    return (data['category'] ?? '') == _categoryFilter;
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
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: kComplaintBlue,
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

  Widget _categoryDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _categoryFilter,
          icon: const Icon(Icons.keyboard_arrow_down, color: kComplaintBlue),
          style: const TextStyle(
            color: Color(0xFF1B1B1B),
            fontSize: 13,
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

  void _showForwardToWardenDialog(String docId, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.forward_to_inbox, color: kComplaintBlue),
            SizedBox(width: 8),
            Text(
              'Forward to Warden',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kComplaintBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['studentName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Room ${data['studentRoom']}  ·  ${data['category']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data['message'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF444444),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kComplaintBlueTint,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kComplaintBlue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.admin_panel_settings,
                        color: kComplaintBlue,
                        size: 20,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Forwarding To',
                            style: TextStyle(
                              fontSize: 11,
                              color: kComplaintBlue,
                            ),
                          ),
                          Text(
                            'Warden',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1B5E20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseFirestore.instance
                    .collection('complaints')
                    .doc(docId)
                    .update({
                      'currentStage': 'Warden',
                      'status': 'pending',
                      'history': FieldValue.arrayUnion([
                        {
                          'stage': 'RT',
                          'action': 'forwarded',
                          'note': 'Forwarded by RT to Warden',
                          'timestamp': DateTime.now().toIso8601String(),
                        },
                      ]),
                    });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Forwarded to Warden',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    backgroundColor: kComplaintBlue,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            icon: const Icon(Icons.send, size: 16),
            label: const Text(
              'Confirm Forward',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kComplaintBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ UPDATED: reason is now mandatory — cannot reject without typing a reason
  void _showRejectDialog(String docId, Map<String, dynamic> data) {
    final ctrl = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.cancel_outlined, color: Color(0xFFDC3545)),
              SizedBox(width: 8),
              Text(
                'Reject Complaint',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFDC3545).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['studentName'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Room ${data['studentRoom']}  ·  ${data['category']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['message'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF444444),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ✅ Removed "(optional)" — reason is now required
                  const Text(
                    'Reason for Rejection:',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: ctrl,
                    maxLines: 3,
                    // ✅ Clear error as user types
                    onChanged: (_) {
                      if (errorText != null) {
                        setDialogState(() => errorText = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter reason...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      // ✅ Shows red error message below field when empty
                      errorText: errorText,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFDC3545),
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFDC3545),
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFDC3545),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // ✅ Block submission if reason is empty
                if (ctrl.text.trim().isEmpty) {
                  setDialogState(
                    () => errorText = 'Please enter a reason for rejection',
                  );
                  return;
                }
                Navigator.pop(ctx);
                try {
                  await FirebaseFirestore.instance
                      .collection('complaints')
                      .doc(docId)
                      .update({
                        'status': 'rejected',
                        'rejectMessage': ctrl.text.trim(),
                        'history': FieldValue.arrayUnion([
                          {
                            'stage': 'RT',
                            'action': 'rejected',
                            'note': ctrl.text.trim(),
                            'timestamp': DateTime.now().toIso8601String(),
                          },
                        ]),
                      });
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Row(
                        children: [
                          Icon(Icons.block, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Complaint rejected',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFDC3545),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              icon: const Icon(Icons.block, size: 16),
              label: const Text(
                'Confirm Reject',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kComplaintBg,
      // ✅ THE FIX: false prevents layout from being squished when keyboard opens
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('complaints').snapshots(),
        builder: (context, snapshot) {
          final allDocs = snapshot.data?.docs ?? [];
          final myDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _isForRT(data);
          }).toList();

          final total = myDocs.length;
          final pending = myDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return _rtAction(data).isEmpty &&
                (data['currentStage'] ?? '') == 'RT';
          }).length;
          final forwarded = myDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return _rtAction(data) == 'forwarded';
          }).length;
          final rejected = myDocs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            return _rtAction(data) == 'rejected';
          }).length;

          return Column(
            children: [
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kComplaintBlue, Color(0xFF1976D2)],
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
                      'RT · Review & Forward',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _statBox(
                          'Total',
                          total,
                          Colors.white.withOpacity(0.25),
                        ),
                        const SizedBox(width: 8),
                        _statBox(
                          'Pending',
                          pending,
                          const Color(0xFFFFC107).withOpacity(0.6),
                        ),
                        const SizedBox(width: 8),
                        _statBox(
                          'Forwarded',
                          forwarded,
                          kComplaintBlue.withOpacity(0.8),
                        ),
                        const SizedBox(width: 8),
                        _statBox(
                          'Rejected',
                          rejected,
                          const Color(0xFFDC3545).withOpacity(0.6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Search bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: kComplaintBlue,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText:
                                      'Search by student, room, category...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                                style: const TextStyle(fontSize: 14),
                                onChanged: (v) => setState(() => _search = v),
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
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedDate == null
                                      ? Colors.white
                                      : kComplaintBlueTint,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: _selectedDate == null
                                        ? Colors.transparent
                                        : kComplaintBlue,
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.06),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      size: 18,
                                      color: kComplaintBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'Filter by date'
                                            : _formatFilterDate(_selectedDate!),
                                        style: TextStyle(
                                          fontSize: 13,
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
                              onTap: () => setState(() => _selectedDate = null),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDEDEE),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Color(0xFFDC3545),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Category dropdown
                      _categoryDropdown(),
                      const SizedBox(height: 10),

                      // Status filter chips
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filters.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final f = filters[i];
                            final active = _filter == f;
                            return GestureDetector(
                              onTap: () => setState(() => _filter = f),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: active ? kComplaintBlue : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: active
                                          ? const Color(
                                              0xFF1565C0,
                                            ).withOpacity(0.35)
                                          : Colors.black.withOpacity(0.07),
                                      blurRadius: active ? 10 : 6,
                                      offset: const Offset(0, 3),
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
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Active date label
                      if (_selectedDate != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: kComplaintBlueTint,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.filter_list,
                                size: 14,
                                color: kComplaintBlue,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Showing complaints for: ${_formatFilterDate(_selectedDate!)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: kComplaintBlue,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Complaints list
                      Expanded(
                        child:
                            snapshot.connectionState == ConnectionState.waiting
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: kComplaintBlue,
                                ),
                              )
                            : () {
                                final filtered =
                                    myDocs.where((doc) {
                                      final data =
                                          doc.data() as Map<String, dynamic>;
                                      return _matchesFilter(data) &&
                                          _matchesSearch(data) &&
                                          _matchesCategory(data) &&
                                          _matchesDate(data);
                                    }).toList()..sort((a, b) {
                                      final aData =
                                          a.data() as Map<String, dynamic>;
                                      final bData =
                                          b.data() as Map<String, dynamic>;
                                      DateTime aTime = DateTime(2000);
                                      DateTime bTime = DateTime(2000);
                                      final aRaw = aData['createdAt'];
                                      final bRaw = bData['createdAt'];
                                      if (aRaw is String) {
                                        aTime =
                                            DateTime.tryParse(aRaw) ?? aTime;
                                      } else if (aRaw != null) {
                                        aTime = (aRaw as dynamic).toDate();
                                      }
                                      if (bRaw is String) {
                                        bTime =
                                            DateTime.tryParse(bRaw) ?? bTime;
                                      } else if (bRaw != null) {
                                        bTime = (bRaw as dynamic).toDate();
                                      }
                                      return bTime.compareTo(aTime);
                                    });

                                if (filtered.isEmpty) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 60,
                                          color: Colors.grey.shade300,
                                        ),
                                        const SizedBox(height: 12),
                                        const Text(
                                          'No complaints found.',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                return ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (_, index) {
                                    final doc = filtered[index];
                                    final data =
                                        doc.data() as Map<String, dynamic>;
                                    final docId = doc.id;
                                    final rtAction = _rtAction(data);
                                    final isForwarded = rtAction == 'forwarded';
                                    final isRejected = rtAction == 'rejected';
                                    final actionDone =
                                        isForwarded || isRejected;

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.07,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(14),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data['studentName'] ??
                                                              'Unknown',
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w800,
                                                                fontSize: 15,
                                                                color: Color(
                                                                  0xFF1B1B1B,
                                                                ),
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 2,
                                                        ),
                                                        Text(
                                                          'Room ${data['studentRoom'] ?? '-'}',
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 12,
                                                                color:
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: isRejected
                                                            ? const Color(
                                                                0xFFFDEDEE,
                                                              )
                                                            : isForwarded
                                                            ? const Color(
                                                                0xFFE8F0FE,
                                                              )
                                                            : const Color(
                                                                0xFFFFF3CD,
                                                              ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Container(
                                                            width: 7,
                                                            height: 7,
                                                            decoration: BoxDecoration(
                                                              color: isRejected
                                                                  ? const Color(
                                                                      0xFFDC3545,
                                                                    )
                                                                  : isForwarded
                                                                  ? const Color(
                                                                      0xFF1565C0,
                                                                    )
                                                                  : const Color(
                                                                      0xFFFFC107,
                                                                    ),
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            width: 5,
                                                          ),
                                                          Text(
                                                            isRejected
                                                                ? 'Rejected'
                                                                : isForwarded
                                                                ? 'Forwarded'
                                                                : 'Pending',
                                                            style: TextStyle(
                                                              color: isRejected
                                                                  ? const Color(
                                                                      0xFF8B0000,
                                                                    )
                                                                  : isForwarded
                                                                  ? const Color(
                                                                      0xFF1B5E20,
                                                                    )
                                                                  : const Color(
                                                                      0xFF856404,
                                                                    ),
                                                              fontSize: 11,
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
                                                const SizedBox(height: 10),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: _categoryColor(
                                                          data['category'] ??
                                                              '',
                                                        ).withOpacity(0.12),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        data['category'] ?? '',
                                                        style: TextStyle(
                                                          color: _categoryColor(
                                                            data['category'] ??
                                                                '',
                                                          ),
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      data['message'] ?? '',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Color(
                                                          0xFF555555,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                if (isForwarded) ...[
                                                  const SizedBox(height: 8),
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.forward_to_inbox,
                                                        size: 13,
                                                        color: Color(
                                                          0xFF1565C0,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Forwarded to Warden',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFF1565C0,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                                if (isRejected) ...[
                                                  const SizedBox(height: 8),
                                                  const Row(
                                                    children: [
                                                      Icon(
                                                        Icons.block,
                                                        size: 13,
                                                        color: Color(
                                                          0xFFDC3545,
                                                        ),
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Rejected by RT',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Color(
                                                            0xFFDC3545,
                                                          ),
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if (!actionDone)
                                            Container(
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF8FFFE),
                                                border: Border(
                                                  top: BorderSide(
                                                    color: Color(0xFFE8F0EC),
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    18,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    18,
                                                  ),
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 10,
                                                  ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _showForwardToWardenDialog(
                                                            docId,
                                                            data,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFE8F0FE,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .forward_to_inbox,
                                                              size: 15,
                                                              color: Color(
                                                                0xFF1565C0,
                                                              ),
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              'Forward to Warden',
                                                              style: TextStyle(
                                                                color: Color(
                                                                  0xFF1565C0,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Expanded(
                                                    child: GestureDetector(
                                                      onTap: () =>
                                                          _showRejectDialog(
                                                            docId,
                                                            data,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              vertical: 10,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFFFDEDEE,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                        child: const Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              size: 15,
                                                              color: Color(
                                                                0xFFDC3545,
                                                              ),
                                                            ),
                                                            SizedBox(width: 6),
                                                            Text(
                                                              'Reject',
                                                              style: TextStyle(
                                                                color: Color(
                                                                  0xFFDC3545,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }(),
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
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
