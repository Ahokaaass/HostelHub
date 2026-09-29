import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MessComplaintsScreen extends StatefulWidget {
  const MessComplaintsScreen({super.key});

  @override
  State<MessComplaintsScreen> createState() => _MessComplaintsScreenState();
}

class _MessComplaintsScreenState extends State<MessComplaintsScreen> {
  String _search = '';

  Future<void> _forwardToMatron(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docId)
          .update({
            'currentStage': 'Matron',
            'currentStageIndex': 2,
            'status': 'pending',
            'history': FieldValue.arrayUnion([
              {
                'stage': 'Mess Secretary',
                'action': 'forwarded',
                'note': 'Forwarded by Mess Secretary to Matron',
                'timestamp': DateTime.now().toIso8601String(),
              },
            ]),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, size: 18),
              SizedBox(width: 8),
              Text('Forwarded to Matron'),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _rejectComplaint(String docId, String message) async {
    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(docId)
          .update({
            'status': 'rejected',
            'rejectMessage': message,
            'history': FieldValue.arrayUnion([
              {
                'stage': 'Mess Secretary',
                'action': 'rejected',
                'note': message,
                'timestamp': DateTime.now().toIso8601String(),
              },
            ]),
          });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.block, size: 18),
              SizedBox(width: 8),
              Text('Complaint rejected'),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _showRejectDialog(String docId) async {
    final ctrl = TextEditingController();
    final rejectedText = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.block_outlined),
            SizedBox(width: 8),
            Text('Reject Complaint'),
          ],
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: const InputDecoration(hintText: 'Reason (optional)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              ctx,
              (ctrl.text.trim().isNotEmpty
                  ? ctrl.text.trim()
                  : 'Rejected by Mess Secretary'),
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (rejectedText == null || rejectedText.trim().isEmpty) return;
    await _rejectComplaint(docId, rejectedText);
  }

  String _latestMessSecretaryAction(Map<String, dynamic> data) {
    final history = List<Map<String, dynamic>>.from(data['history'] ?? []);
    final entry = history.lastWhere(
      (h) => h['stage'] == 'Mess Secretary',
      orElse: () => <String, dynamic>{},
    );
    return (entry['action'] ?? '').toString();
  }

  String _statusLabel(String action) {
    switch (action) {
      case 'forwarded':
        return 'Forwarded';
      case 'rejected':
        return 'Rejected';
      case 'accepted':
        return 'Accepted';
      default:
        return 'Pending';
    }
  }

  Color _statusColor(String action) {
    switch (action) {
      case 'forwarded':
        return Colors.blue.withOpacity(0.18);
      case 'rejected':
        return Colors.red.withOpacity(0.15);
      case 'accepted':
        return Colors.green.withOpacity(0.15);
      default:
        return Colors.amber.withOpacity(0.18);
    }
  }

  Color _statusTextColor(String action) {
    switch (action) {
      case 'forwarded':
        return Colors.blue.shade800;
      case 'rejected':
        return Colors.red.shade700;
      case 'accepted':
        return Colors.green.shade800;
      default:
        return Colors.brown.shade800;
    }
  }

  bool _matchesSearch(Map<String, dynamic> data) {
    if (_search.trim().isEmpty) return true;
    final q = _search.toLowerCase();
    final name = (data['studentName'] ?? '').toString().toLowerCase();
    final room = (data['studentRoom'] ?? '').toString().toLowerCase();
    final msg = (data['message'] ?? '').toString().toLowerCase();
    return name.contains(q) || room.contains(q) || msg.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    const titleStyle = TextStyle(fontWeight: FontWeight.w900, fontSize: 14);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      appBar: AppBar(title: const Text('Mess Complaints')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by student, room, or message',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('complaints')
                    .where('category', isEqualTo: 'Mess Complaint')
                    .where('currentStage', isEqualTo: 'Mess Secretary')
                    .snapshots(),
                builder: (context, snapshot) {
                  final docs = snapshot.data?.docs ?? [];
                  final filtered = docs.where((d) {
                    final data = d.data() as Map<String, dynamic>;
                    return _matchesSearch(data);
                  }).toList();

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (filtered.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'No pending mess complaints for you.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final doc = filtered[i];
                      final id = doc.id;
                      final data = doc.data() as Map<String, dynamic>;
                      final action = _latestMessSecretaryAction(data);

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.report_problem_outlined),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      data['studentName']?.toString() ??
                                          'Unknown',
                                      style: titleStyle,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Room ${data['studentRoom']?.toString() ?? '-'}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                data['message']?.toString() ?? '',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(action),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      _statusLabel(action),
                                      style: TextStyle(
                                        color: _statusTextColor(action),
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (action.isEmpty) ...[
                                    Row(
                                      children: [
                                        FilledButton.tonal(
                                          onPressed: () => _forwardToMatron(id),
                                          child: const Text('Forward'),
                                        ),
                                        const SizedBox(width: 8),
                                        FilledButton(
                                          onPressed: () =>
                                              _showRejectDialog(id),
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade600,
                                          ),
                                          child: const Text('Reject'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
