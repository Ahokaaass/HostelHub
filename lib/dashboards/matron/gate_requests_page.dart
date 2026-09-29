// ============================================================
// FILE: lib/dashboards/matron/gate_requests_page.dart
// ============================================================
//
// IMPORTANT: In gate_request_model.dart, add this method to GateRequestService:
//
//   static Stream<List<GateRequest>> streamForMatronAll() {
//     return FirebaseFirestore.instance
//         .collection('gateRequests')
//         .where('status', whereIn: [
//           GateStatus.pending,
//           GateStatus.matronForward,
//           GateStatus.matronDecline,
//         ])
//         .snapshots()
//         .map((s) => s.docs.map((d) => GateRequest.fromMap(d.data(), d.id)).toList());
//   }
//
// ============================================================

import 'package:flutter/material.dart';
import '../../model/gate_request_model.dart';

const _kPrimary = Color(0xFF1565C0);
const _kBg = Color(0xFFF4F6FB);

/// ─── MAIN LIST PAGE ──────────────────────────────────────────────────────────
class GateRequestsPage extends StatefulWidget {
  const GateRequestsPage({super.key});

  @override
  State<GateRequestsPage> createState() => _GateRequestsPageState();
}

class _GateRequestsPageState extends State<GateRequestsPage> {
  String _filter = 'All';
  String _search = '';

  static const _filters = ['All', 'Pending', 'Forwarded', 'Declined'];

  List<GateRequest> _applyFilter(List<GateRequest> all) {
    var list = all;
    if (_search.trim().isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where(
            (r) =>
                r.name.toLowerCase().contains(q) ||
                r.room.toLowerCase().contains(q) ||
                r.type.toLowerCase().contains(q),
          )
          .toList();
    }
    switch (_filter) {
      case 'Pending':
        return list.where((r) => r.status == GateStatus.pending).toList();
      case 'Forwarded':
        return list.where((r) => r.status == GateStatus.matronForward).toList();
      case 'Declined':
        return list.where((r) => r.status == GateStatus.matronDecline).toList();
      default:
        return list;
    }
  }

  int _count(List<GateRequest> all, String s) =>
      all.where((r) => r.status == s).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<List<GateRequest>>(
        // streamForMatronAll() fetches pending + forwarded + declined
        // so previously actioned requests stay visible in the list.
        stream: GateRequestService.streamForMatronAll(),
        builder: (context, snap) {
          final all = snap.data ?? [];
          final filtered = _applyFilter(all);
          final isLoading = snap.connectionState == ConnectionState.waiting;

          return Column(
            children: [
              // ── Gradient header ──────────────────────────────────────────
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 12, 16, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(6),
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
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 4),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gate Requests',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 21,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Text(
                                  'Gate Requests – Matron',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Stat cards
                        Row(
                          children: [
                            _StatCard(
                              label: 'Total',
                              count: all.length,
                              color: const Color(0xFF1E88E5),
                            ),
                            const SizedBox(width: 8),
                            _StatCard(
                              label: 'Pending',
                              count: _count(all, GateStatus.pending),
                              color: const Color(0xFF827717),
                            ),
                            const SizedBox(width: 8),
                            _StatCard(
                              label: 'Forwarded',
                              count: _count(all, GateStatus.matronForward),
                              color: const Color(0xFF1565C0),
                            ),
                            const SizedBox(width: 8),
                            _StatCard(
                              label: 'Declined',
                              count: _count(all, GateStatus.matronDecline),
                              color: const Color(0xFF6A1B4D),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Search ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE0E7F0)),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _search = v),
                    decoration: const InputDecoration(
                      hintText: 'Search by name, room, type...',
                      hintStyle: TextStyle(
                        color: Color(0xFFB0BEC5),
                        fontSize: 13.5,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF90A4AE),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),
                ),
              ),

              // ── Filter chips ─────────────────────────────────────────────
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) {
                    final f = _filters[i];
                    final sel = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? _kPrimary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? _kPrimary : const Color(0xFFDDE3EE),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : const Color(0xFF607D8B),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // ── List ─────────────────────────────────────────────────────
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : snap.hasError
                    ? Center(
                        child: Text(
                          'Error: ${snap.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                    : filtered.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 56,
                              color: Color(0xFFB0BEC5),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'No requests found',
                              style: TextStyle(
                                color: Color(0xFF90A4AE),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _RequestCard(
                          request: filtered[i],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GateRequestDetailPage(
                                requestId: filtered[i].id,
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatCard({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    ),
  );
}

// ── Request card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final GateRequest request;
  final VoidCallback onTap;
  const _RequestCard({required this.request, required this.onTap});

  bool get _isPending => request.status == GateStatus.pending;
  bool get _isForwarded => request.status == GateStatus.matronForward;
  bool get _isDeclined => request.status == GateStatus.matronDecline;

  Color get _badgeColor {
    if (_isPending) return const Color(0xFFF57F17);
    if (_isForwarded) return _kPrimary;
    return const Color(0xFFD32F2F);
  }

  String get _badgeLabel {
    if (_isPending) return 'Pending';
    if (_isForwarded) return 'Forwarded';
    return 'Declined';
  }

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E7F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name + badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Room ${r.room}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF78909C),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _badgeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _badgeColor.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: _badgeColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _badgeLabel,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: _badgeColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Type chip + date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      r.type,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: _kPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 12,
                    color: Color(0xFF90A4AE),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${r.date}  ${r.time}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF78909C),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Reason preview
              Text(
                r.reason,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF546E7A)),
              ),

              // ── Footer: action buttons OR previous result ─────────────
              if (_isPending) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ActionBtn(
                        label: 'Forward to RT',
                        icon: Icons.forward_to_inbox_rounded,
                        color: _kPrimary,
                        onTap: () => _forward(context, r),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionBtn(
                        label: 'Decline',
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFD32F2F),
                        outlined: true,
                        onTap: () => _showDeclineDialog(context, r),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const Divider(height: 20, color: Color(0xFFF0F4F8)),
                if (_isForwarded)
                  Row(
                    children: [
                      const Icon(
                        Icons.forward_to_inbox_rounded,
                        size: 15,
                        color: _kPrimary,
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        'Forwarded to RT',
                        style: TextStyle(
                          fontSize: 13,
                          color: _kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                else if (_isDeclined)
                  Row(
                    children: [
                      const Icon(
                        Icons.cancel_outlined,
                        size: 15,
                        color: Color(0xFFD32F2F),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          r.matronDeclineReason ?? 'Request declined',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFFD32F2F),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _forward(BuildContext context, GateRequest r) async {
    try {
      await GateRequestService.updateStatus(r.id, {
        'status': GateStatus.matronForward,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forwarded to RT successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDeclineDialog(BuildContext context, GateRequest r) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reason for Declining',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter a reason:',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF607D8B)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E7F0)),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter reason...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF607D8B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await GateRequestService.updateStatus(r.id, {
                'status': GateStatus.matronDecline,
                'matronDeclineReason': ctrl.text.trim(),
              });
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}

// ── Small action button ───────────────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool outlined;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: outlined ? Colors.white : color.withOpacity(0.08),
    borderRadius: BorderRadius.circular(10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: outlined ? color.withOpacity(0.4) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// ─── DETAIL PAGE ─────────────────────────────────────────────────────────────
class GateRequestDetailPage extends StatelessWidget {
  final String requestId;
  const GateRequestDetailPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<GateRequest?>(
        stream: GateRequestService.streamSingle(requestId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(
              child: Text(
                'Error: ${snap.error ?? 'Not found'}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return _DetailBody(request: snap.data!);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final GateRequest request;
  const _DetailBody({required this.request});

  bool get _isPending => request.status == GateStatus.pending;
  bool get _isDeclined => request.status == GateStatus.matronDecline;
  bool get _isForwarded => request.status == GateStatus.matronForward;

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Column(
      children: [
        // ── Header ──────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 16, 22),
              child: Row(
                children: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Request Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Spacer(),
                  // Status pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isDeclined
                              ? Icons.cancel
                              : _isForwarded
                              ? Icons.check_circle
                              : Icons.hourglass_top,
                          color: Colors.white,
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isDeclined
                              ? 'Declined'
                              : _isForwarded
                              ? 'Forwarded'
                              : 'Pending',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Body ────────────────────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                _card(
                  children: [
                    Text(
                      r.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.door_back_door_outlined,
                          size: 14,
                          color: Color(0xFF90A4AE),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Room ${r.room}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF78909C),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: Color(0xFF90A4AE),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          r.phone,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF78909C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Type chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        r.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Date highlight
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_rounded,
                            size: 15,
                            color: _kPrimary,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Incident Date & Time',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _kPrimary,
                                ),
                              ),
                              Text(
                                '${r.date}  ·  ${r.time}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Color(0xFF1A1A2E),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Reason',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.reason,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF37474F),
                      ),
                    ),
                  ],
                ),

                // Result banner for already-actioned requests
                if (!_isPending)
                  _card(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (_isDeclined ? Colors.red : Colors.green)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isDeclined
                                  ? Icons.cancel_rounded
                                  : Icons.check_circle_rounded,
                              color: _isDeclined ? Colors.red : Colors.green,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _isDeclined
                                      ? 'Request Declined'
                                      : 'Forwarded to RT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: _isDeclined
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isDeclined
                                      ? (r.matronDeclineReason ??
                                            'Declined by matron')
                                      : 'Request has been forwarded to RT for review',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF78909C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                // Action buttons — only for pending
                if (_isPending)
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.forward_to_inbox_rounded,
                              size: 18,
                            ),
                            label: const Text(
                              'Forward to RT',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () => _forward(context, r),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: const Text(
                              'Decline',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => _showDeclineDialog(context, r),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _card({required List<Widget> children}) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE0E7F0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );

  Future<void> _forward(BuildContext context, GateRequest r) async {
    try {
      await GateRequestService.updateStatus(r.id, {
        'status': GateStatus.matronForward,
      });
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _showDeclineDialog(BuildContext context, GateRequest r) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Reason for Declining',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please enter a reason:',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF607D8B)),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE0E7F0)),
              ),
              child: TextField(
                controller: ctrl,
                maxLines: 3,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Enter reason...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF607D8B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await GateRequestService.updateStatus(r.id, {
                'status': GateStatus.matronDecline,
                'matronDeclineReason': ctrl.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}
