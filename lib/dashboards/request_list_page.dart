import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../model/gate_request_model.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlueDark = Color(0xFF0D47A1);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint = Color(0xFFE8F0FE);
const _kBg = Color(0xFFF4F6FB);

enum ViewerRole { matron, rt, warden, office }

class RequestListPage extends StatefulWidget {
  final ViewerRole role;

  const RequestListPage({super.key, this.role = ViewerRole.rt});

  @override
  State<RequestListPage> createState() => _RequestListPageState();
}

class _RequestListPageState extends State<RequestListPage> {
  String _filter = 'All';
  String _search = '';

  final _filters = ['All', 'Pending', 'Forwarded', 'Declined'];

  String get _pendingStatus {
    switch (widget.role) {
      case ViewerRole.matron:
        return GateStatus.pending;
      case ViewerRole.rt:
        return GateStatus.matronForward;
      case ViewerRole.warden:
        return GateStatus.rtForward;
      case ViewerRole.office:
        return GateStatus.wardenAccept;
    }
  }

  Stream<QuerySnapshot> get _allStream =>
      FirebaseFirestore.instance.collection('gate_requests').snapshots();

  bool _isDeclinedByMe(GateRequest r) {
    switch (widget.role) {
      case ViewerRole.matron:
        return r.status == GateStatus.matronDecline;
      case ViewerRole.rt:
        return r.status == GateStatus.rtDecline;
      case ViewerRole.warden:
        return r.status == GateStatus.wardenReject;
      case ViewerRole.office:
        return false;
    }
  }

  bool _isForwardedByMe(GateRequest r) {
    switch (widget.role) {
      case ViewerRole.matron:
        return r.status == GateStatus.matronForward ||
            r.status == GateStatus.rtForward ||
            r.status == GateStatus.rtDecline ||
            r.status == GateStatus.wardenAccept ||
            r.status == GateStatus.wardenReject ||
            r.status == GateStatus.securityDone;
      case ViewerRole.rt:
        return r.status == GateStatus.rtForward ||
            r.status == GateStatus.wardenAccept ||
            r.status == GateStatus.wardenReject ||
            r.status == GateStatus.securityDone;
      case ViewerRole.warden:
        return r.status == GateStatus.wardenAccept ||
            r.status == GateStatus.securityDone;
      case ViewerRole.office:
        return r.status == GateStatus.securityDone;
    }
  }

  String get _forwardLabel {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'Forward to RT';
      case ViewerRole.rt:
        return 'Forward to Warden';
      case ViewerRole.warden:
        return 'Accept';
      case ViewerRole.office:
        return 'Mark Done';
    }
  }

  String get _declineLabel {
    switch (widget.role) {
      case ViewerRole.matron:
      case ViewerRole.rt:
        return 'Decline';
      case ViewerRole.warden:
        return 'Reject';
      case ViewerRole.office:
        return 'Close';
    }
  }

  String get _pageTitle {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'Gate Requests - Matron';
      case ViewerRole.rt:
        return 'Gate Requests - RT';
      case ViewerRole.warden:
        return 'Gate Requests - Warden';
      case ViewerRole.office:
        return 'Gate Requests - Security';
    }
  }

  bool _matchSearch(GateRequest r) {
    if (_search.isEmpty) return true;
    final q = _search.toLowerCase();
    return r.name.toLowerCase().contains(q) ||
        r.room.toLowerCase().contains(q) ||
        r.type.toLowerCase().contains(q);
  }

  String get _nextRoleLabel {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'RT';
      case ViewerRole.rt:
        return 'Warden';
      case ViewerRole.warden:
        return 'Security';
      case ViewerRole.office:
        return 'Completed';
    }
  }

  String get _forwardStatus {
    switch (widget.role) {
      case ViewerRole.matron:
        return GateStatus.matronForward;
      case ViewerRole.rt:
        return GateStatus.rtForward;
      case ViewerRole.warden:
        return GateStatus.wardenAccept;
      case ViewerRole.office:
        return GateStatus.securityDone;
    }
  }

  String get _declineStatus {
    switch (widget.role) {
      case ViewerRole.matron:
        return GateStatus.matronDecline;
      case ViewerRole.rt:
        return GateStatus.rtDecline;
      case ViewerRole.warden:
        return GateStatus.wardenReject;
      case ViewerRole.office:
        return GateStatus.securityDone;
    }
  }

  String get _declineReasonKey {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'matronDeclineReason';
      case ViewerRole.rt:
        return 'rtDeclineReason';
      case ViewerRole.warden:
        return 'wardenRejectReason';
      case ViewerRole.office:
        return 'securityNote';
    }
  }

  String get _forwardedToLabel {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'Forwarded to RT';
      case ViewerRole.rt:
        return 'Forwarded to Warden';
      case ViewerRole.warden:
        return 'Accepted - At Security';
      case ViewerRole.office:
        return 'Completed at Security';
    }
  }

  String get _declinedByLabel {
    switch (widget.role) {
      case ViewerRole.matron:
        return 'Declined by Matron';
      case ViewerRole.rt:
        return 'Declined by RT';
      case ViewerRole.warden:
        return 'Rejected by Warden';
      case ViewerRole.office:
        return 'Closed by Security';
    }
  }

  String _declineReason(GateRequest r) {
    switch (widget.role) {
      case ViewerRole.matron:
        return r.matronDeclineReason ?? '';
      case ViewerRole.rt:
        return r.rtDeclineReason ?? '';
      case ViewerRole.warden:
        return r.wardenRejectReason ?? '';
      case ViewerRole.office:
        return '';
    }
  }

  DateTime _sortDateTime(GateRequest r) {
    final ts = r.createdAt;
    if (ts != null) return ts.toDate();

    final dateParts = r.date.split('/');
    if (dateParts.length == 3) {
      final day = int.tryParse(dateParts[0]) ?? 1;
      final month = int.tryParse(dateParts[1]) ?? 1;
      final year = int.tryParse(dateParts[2]) ?? 2000;

      final timeMatch = RegExp(
        r'^\s*(\d{1,2})[:.](\d{2})\s*([APap][Mm])?\s*$',
      ).firstMatch(r.time);

      if (timeMatch != null) {
        var hour = int.tryParse(timeMatch.group(1)!) ?? 0;
        final minute = int.tryParse(timeMatch.group(2)!) ?? 0;
        final suffix = (timeMatch.group(3) ?? '').toUpperCase();

        if (suffix == 'PM' && hour < 12) hour += 12;
        if (suffix == 'AM' && hour == 12) hour = 0;

        return DateTime(year, month, day, hour, minute);
      }

      return DateTime(year, month, day);
    }

    return DateTime(2000);
  }

  int _sortPriority(GateRequest r) {
    if (r.status == _pendingStatus) return 0;
    if (_isDeclinedByMe(r)) return 2;
    return 1;
  }

  List<GateRequest> _requestsForRole(List<GateRequest> all) {
    return all.where((r) {
      switch (widget.role) {
        case ViewerRole.matron:
          return r.status == GateStatus.pending ||
              r.status == GateStatus.matronForward ||
              r.status == GateStatus.matronDecline;
        case ViewerRole.rt:
          return r.status == GateStatus.matronForward ||
              r.status == GateStatus.rtForward ||
              r.status == GateStatus.rtDecline ||
              r.status == GateStatus.wardenAccept ||
              r.status == GateStatus.wardenReject ||
              r.status == GateStatus.securityDone;
        case ViewerRole.warden:
          return r.status == GateStatus.rtForward ||
              r.status == GateStatus.wardenAccept ||
              r.status == GateStatus.wardenReject ||
              r.status == GateStatus.securityDone;
        case ViewerRole.office:
          return r.status == GateStatus.wardenAccept ||
              r.status == GateStatus.securityDone;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: _allStream,
        builder: (context, allSnap) {
          if (allSnap.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _kBlue),
            );
          }
          if (allSnap.hasError) {
            return Center(child: Text('Error: ${allSnap.error}'));
          }

          final allDocs =
              allSnap.data?.docs.map((d) => GateRequest.fromDoc(d)).toList() ??
              const <GateRequest>[];
          final allForRole = _requestsForRole(allDocs);
          final total = allForRole.length;
          final pending =
              allForRole.where((r) => r.status == _pendingStatus).length;
          final forwarded = allForRole.where(_isForwardedByMe).length;
          final declined = allForRole.where(_isDeclinedByMe).length;

          final visible = allForRole.where((r) {
            if (!_matchSearch(r)) return false;
            switch (_filter) {
              case 'Pending':
                return r.status == _pendingStatus;
              case 'Forwarded':
                return _isForwardedByMe(r);
              case 'Declined':
                return _isDeclinedByMe(r);
              default:
                return true;
            }
          }).toList();

          visible.sort((a, b) {
            final priorityCompare =
                _sortPriority(a).compareTo(_sortPriority(b));
            if (priorityCompare != 0) return priorityCompare;
            return _sortDateTime(b).compareTo(_sortDateTime(a));
          });

          return Column(
            children: [
              _header(context, total, pending, forwarded, declined),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _searchBox(),
                      const SizedBox(height: 10),
                      _filterTabs(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: visible.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 60,
                                      color: Colors.grey.shade300,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No requests found.',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: visible.length,
                                itemBuilder: (_, i) => _card(visible[i]),
                              ),
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

  Widget _header(
    BuildContext context,
    int total,
    int pending,
    int forwarded,
    int declined,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_kBlueDark, _kBlueLight],
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
                    color: Colors.white.withValues(alpha: 0.2),
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
                "Gate Requests",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _pageTitle,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _statBox('Total', total, Colors.white.withValues(alpha: 0.25)),
              const SizedBox(width: 8),
              _statBox(
                'Pending',
                pending,
                const Color(0xFFFFC107).withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              _statBox(
                'Forwarded',
                forwarded,
                _kBlueLight.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              _statBox(
                'Declined',
                declined,
                const Color(0xFFDC3545).withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: _kBlueLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name, room, type...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              style: const TextStyle(fontSize: 14),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTabs() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final active = _filter == f;
          return GestureDetector(
            onTap: () => setState(() => _filter = f),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
              decoration: BoxDecoration(
                color: active ? _kBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? _kBlueDark.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: active ? 10 : 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                f,
                style: TextStyle(
                  color: active ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _card(GateRequest r) {
    final isPending = r.status == _pendingStatus;
    final isForwarded = _isForwardedByMe(r);
    final isDeclined = _isDeclinedByMe(r);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Color(0xFF1B1B1B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Room ${r.room}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    _statusBadge(isDeclined, isForwarded),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _kBlueTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        r.type,
                        style: const TextStyle(
                          color: _kBlue,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "${r.date}  ${r.time}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  r.reason,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isForwarded) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.forward_to_inbox,
                        size: 13,
                        color: _kBlueLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _forwardedToLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _kBlueLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (isDeclined) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.block,
                        size: 13,
                        color: Color(0xFFDC3545),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _declinedByLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC3545),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (_declineReason(r).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, left: 17),
                      child: Text(
                        _declineReason(r),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (isPending)
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFE),
                border: Border(top: BorderSide(color: Color(0xFFE3ECF8))),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: _actionBtn(
                      label: _forwardLabel,
                      icon: Icons.forward_to_inbox,
                      color: _kBlueLight,
                      bg: _kBlueTint,
                      onTap: () => _showForwardDialog(r),
                    ),
                  ),
                  if (widget.role != ViewerRole.office) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionBtn(
                        label: _declineLabel,
                        icon: Icons.cancel_outlined,
                        color: const Color(0xFFDC3545),
                        bg: const Color(0xFFFDEDEE),
                        onTap: () => _showDeclineDialog(r),
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

  Widget _statusBadge(bool isDeclined, bool isForwarded) {
    late Color bg;
    late Color dotColor;
    late String label;
    late Color textColor;

    if (isDeclined) {
      bg = const Color(0xFFFDEDEE);
      dotColor = const Color(0xFFDC3545);
      label = 'Declined';
      textColor = const Color(0xFF8B0000);
    } else if (isForwarded) {
      bg = _kBlueTint;
      dotColor = _kBlueLight;
      label = 'Forwarded';
      textColor = const Color(0xFF1B5E20);
    } else {
      bg = const Color(0xFFFFF3CD);
      dotColor = const Color(0xFFFFC107);
      label = 'Pending';
      textColor = const Color(0xFF856404);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForwardDialog(GateRequest r) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.forward_to_inbox, color: _kBlueLight),
            const SizedBox(width: 8),
            Text(
              _forwardLabel,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogInfoBox(r),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: _kBlueLight, size: 20),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forwarding To',
                        style: TextStyle(fontSize: 11, color: _kBlueLight),
                      ),
                      Text(
                        _nextRoleLabel,
                        style: const TextStyle(
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
                await GateRequestService.updateStatus(r.id, {
                  'status': _forwardStatus,
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.role == ViewerRole.office
                                ? 'Request marked completed'
                                : 'Forwarded to $_nextRoleLabel',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: _kBlueLight,
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
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kBlueLight,
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

  void _showDeclineDialog(GateRequest r) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: Color(0xFFDC3545)),
            const SizedBox(width: 8),
            Text(
              '${_declineLabel} Request',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogInfoBox(r, red: true),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Reason (optional):',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter reason...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
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
              ),
            ),
          ],
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
                await GateRequestService.updateStatus(r.id, {
                  'status': _declineStatus,
                  _declineReasonKey: ctrl.text.trim().isEmpty
                      ? null
                      : ctrl.text.trim(),
                });
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.block, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          widget.role == ViewerRole.warden
                              ? 'Request rejected'
                              : 'Request declined',
                          style: const TextStyle(fontWeight: FontWeight.w700),
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
              'Confirm',
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
    );
  }

  Widget _dialogInfoBox(GateRequest r, {bool red = false}) {
    final bg = red ? const Color(0xFFFFF5F5) : const Color(0xFFF4F6FB);
    final border = red ? const Color(0xFFDC3545) : Colors.transparent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          Text(
            'Room ${r.room}  |  ${r.type}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            r.reason,
            style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, int count, Color color) {
    return Expanded(
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
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}