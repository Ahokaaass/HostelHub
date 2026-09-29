import 'package:flutter/material.dart';

import '../../core/session.dart';
import '../../model/gate_request_model.dart';
import '../../student/student_data.dart';

const stages = ["Submitted", "Matron", "RT", "Warden"];

int _stageIndex(String status) {
  switch (status) {
    case GateStatus.pending:
      return 0;
    case GateStatus.matronForward:
    case GateStatus.matronDecline:
      return 1;
    case GateStatus.rtForward:
    case GateStatus.rtDecline:
      return 2;
    case GateStatus.wardenAccept:
    case GateStatus.wardenReject:
    case GateStatus.securityDone:
      return 3;
    default:
      return 0;
  }
}

bool _isDeclined(String status) =>
    status == GateStatus.matronDecline ||
    status == GateStatus.rtDecline ||
    status == GateStatus.wardenReject;

DateTime _requestSortDateTime(GateRequest r) {
  if (r.createdAt != null) return r.createdAt!.toDate();
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

// ── Shared colour constants ───────────────────────────────────────────────────
const _kPrimary = Color(0xFF1565C0);
const _kBg = Color(0xFFF4F6FB);

Color _badgeColor(GateRequest r) {
  if (_isDeclined(r.status)) return const Color(0xFFD32F2F);
  if (r.status == GateStatus.wardenAccept ||
      r.status == GateStatus.securityDone) {
    return const Color(0xFF2E7D32);
  }
  if (r.status == GateStatus.pending) return const Color(0xFFF57F17);
  return _kPrimary;
}

String _badgeLabel(GateRequest r) {
  if (_isDeclined(r.status)) return 'Rejected';
  if (r.status == GateStatus.wardenAccept ||
      r.status == GateStatus.securityDone) {
    return 'Approved';
  }
  if (r.status == GateStatus.pending) return 'Pending';
  return 'Active';
}

String _stageLabel(GateRequest r) => 'Stage: ${stages[_stageIndex(r.status)]}';

// ── Shared gradient header ────────────────────────────────────────────────────
class _GradientHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  const _GradientHeader({required this.title, this.subtitle, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── HOME ────────────────────────────────────────────────────────────────────
class GateRequestHome extends StatelessWidget {
  const GateRequestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const _GradientHeader(title: 'Gate Request'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ActionCard(
                    icon: Icons.add_circle_outline_rounded,
                    title: 'New Request',
                    subtitle: 'Submit a late / early entry or going request',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GateRequestForm(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ActionCard(
                    icon: Icons.list_alt_rounded,
                    title: 'My Requests',
                    subtitle: 'Track all your submitted gate requests',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ViewGateRequests(),
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE0E7F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _kPrimary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF78909C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFB0BEC5)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── REQUEST FORM ────────────────────────────────────────────────────────────
class GateRequestForm extends StatefulWidget {
  const GateRequestForm({super.key});

  @override
  State<GateRequestForm> createState() => _GateRequestFormState();
}

class _GateRequestFormState extends State<GateRequestForm> {
  final _reason = TextEditingController();
  String _type = 'Late Entry';
  DateTime? _date;
  TimeOfDay? _time;
  bool _loading = false;

  String _fmtD(DateTime d) => '${d.day}/${d.month}/${d.year}';
  String _fmtT(TimeOfDay t) => t.format(context);

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isTooEarly(TimeOfDay p) {
    if (_date == null || !_isToday(_date!)) return false;
    final now = DateTime.now();
    return p.hour * 60 + p.minute < now.hour * 60 + now.minute;
  }

  Future<void> _submit() async {
    if (_date == null || _time == null) {
      _snack('Select date and time');
      return;
    }
    if (_reason.text.trim().isEmpty) {
      _snack('Please enter a reason');
      return;
    }
    setState(() => _loading = true);
    try {
      await GateRequestService.submit(
        GateRequest(
          id: '',
          type: _type,
          name: StudentData.name,
          room: StudentData.room,
          phone: StudentData.phone,
          date: _fmtD(_date!),
          time: _fmtT(_time!),
          reason: _reason.text.trim(),
          studentId: Session.userId ?? '',
        ),
      );
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Request Submitted'),
          content: const Text(
            'Your gate request has been submitted successfully.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _snack('Failed to submit: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const _GradientHeader(title: 'New Gate Request'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Forwarding chain ──────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF90CAF9)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.alt_route_rounded,
                              size: 15,
                              color: _kPrimary,
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Forwarding Chain',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: _kPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Submitted  →  Matron  →  RT  →  Warden',
                          style: TextStyle(fontSize: 12, color: _kPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Student info (complaint-style) ────────────────────────
                  _whiteCard(
                    child: Column(
                      children: [
                        _infoRow(
                          Icons.person_outline_rounded,
                          'Name',
                          StudentData.name,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: Color(0xFFF0F4F8)),
                        ),
                        _infoRow(
                          Icons.door_back_door_outlined,
                          'Room',
                          StudentData.room,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(height: 1, color: Color(0xFFF0F4F8)),
                        ),
                        _infoRow(
                          Icons.phone_outlined,
                          'Phone',
                          StudentData.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Request type ──────────────────────────────────────────
                  _sectionLabel('Request Type'),
                  const SizedBox(height: 8),
                  _whiteCard(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Late Entry',
                          child: Text('Late Entry'),
                        ),
                        DropdownMenuItem(
                          value: 'Late Going',
                          child: Text('Late Going'),
                        ),
                        DropdownMenuItem(
                          value: 'Early Entry',
                          child: Text('Early Entry'),
                        ),
                        DropdownMenuItem(
                          value: 'Early Going',
                          child: Text('Early Going'),
                        ),
                      ],
                      onChanged: (v) => setState(() {
                        _type = v!;
                        _time = null;
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date & Time ───────────────────────────────────────────
                  _sectionLabel('Incident Date & Time'),
                  const SizedBox(height: 8),
                  _whiteCard(
                    child: Row(
                      children: [
                        // Date picker
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final p = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (p != null) {
                                setState(() {
                                  _date = p;
                                  _time = null;
                                });
                              }
                            },
                            child: _dateTimeCell(
                              label: 'Date',
                              value: _date == null ? null : _fmtD(_date!),
                              icon: Icons.calendar_today_rounded,
                              placeholder: 'Select date',
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: const Color(0xFFECEFF1),
                        ),
                        const SizedBox(width: 14),
                        // Time picker
                        Expanded(
                          child: GestureDetector(
                            onTap: _date == null
                                ? null
                                : () async {
                                    final initial = _isToday(_date!)
                                        ? TimeOfDay.now()
                                        : const TimeOfDay(hour: 0, minute: 0);
                                    final p = await showTimePicker(
                                      context: context,
                                      initialTime: initial,
                                    );
                                    if (p == null || !mounted) return;
                                    if (_isTooEarly(p)) {
                                      _snack(
                                        'Cannot select a time that has already passed',
                                      );
                                      return;
                                    }
                                    setState(() => _time = p);
                                  },
                            child: _dateTimeCell(
                              label: 'Time',
                              value: _time == null ? null : _fmtT(_time!),
                              icon: Icons.access_time_rounded,
                              placeholder: 'Select time',
                              disabled: _date == null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Reason ────────────────────────────────────────────────
                  _sectionLabel('Describe Your Reason'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0E7F0)),
                    ),
                    child: TextField(
                      controller: _reason,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write your reason here...',
                        hintStyle: TextStyle(
                          color: Color(0xFFB0BEC5),
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit Request',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _sectionLabel(String t) => Text(
    t,
    style: const TextStyle(
      fontWeight: FontWeight.w700,
      fontSize: 13.5,
      color: Color(0xFF455A64),
      letterSpacing: 0.1,
    ),
  );

  Widget _whiteCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE0E7F0)),
    ),
    child: child,
  );

  Widget _infoRow(IconData icon, String label, String value) => Row(
    children: [
      Icon(icon, size: 17, color: _kPrimary),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    ],
  );

  Widget _dateTimeCell({
    required String label,
    required String? value,
    required IconData icon,
    required String placeholder,
    bool disabled = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
      ),
      const SizedBox(height: 4),
      Row(
        children: [
          Icon(
            icon,
            size: 14,
            color: disabled ? const Color(0xFFCFD8DC) : _kPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            value ?? placeholder,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: value == null
                  ? const Color(0xFFB0BEC5)
                  : const Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    ],
  );
}

/// ─── VIEW REQUESTS ───────────────────────────────────────────────────────────
class ViewGateRequests extends StatelessWidget {
  const ViewGateRequests({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = Session.userId ?? '';

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          const _GradientHeader(
            title: 'My Requests',
            subtitle: 'Track all your submitted gate requests',
          ),
          Expanded(
            child: StreamBuilder<List<GateRequest>>(
              stream: GateRequestService.streamForStudent(uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Could not load requests.',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snap.error}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final requests = [...(snap.data ?? [])]
                  ..sort(
                    (a, b) => _requestSortDateTime(
                      b,
                    ).compareTo(_requestSortDateTime(a)),
                  );

                if (requests.isEmpty) {
                  return const Center(
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
                          'No requests yet',
                          style: TextStyle(
                            color: Color(0xFF90A4AE),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final r = requests[i];
                    final badge = _badgeColor(r);
                    final declined = _isDeclined(r.status);
                    final approved =
                        r.status == GateStatus.wardenAccept ||
                        r.status == GateStatus.securityDone;

                    return Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GateRequestDetail(request: r),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE0E7F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type + badge
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk_rounded,
                                    size: 17,
                                    color: _kPrimary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    r.type,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: _kPrimary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badge.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: badge.withOpacity(0.5),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: badge,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _badgeLabel(r),
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: badge,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 13,
                                    color: Color(0xFF90A4AE),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${r.date}  ·  ${r.time}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF1E88E5),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 13,
                                    color: Color(0xFF90A4AE),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _stageLabel(r),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF78909C),
                                    ),
                                  ),
                                ],
                              ),
                              if (declined) ...[
                                const SizedBox(height: 8),
                                _banner(
                                  bg: const Color(0xFFFFEBEE),
                                  icon: Icons.cancel_outlined,
                                  iconColor: Colors.red,
                                  text:
                                      r.matronDeclineReason ??
                                      r.rtDeclineReason ??
                                      r.wardenRejectReason ??
                                      'Request was declined',
                                  textColor: Colors.red,
                                ),
                              ] else if (approved) ...[
                                const SizedBox(height: 8),
                                _banner(
                                  bg: const Color(0xFFE8F5E9),
                                  icon: Icons.check_circle_outline,
                                  iconColor: Colors.green,
                                  text: 'Your request has been approved.',
                                  textColor: Colors.green,
                                ),
                              ],
                              const SizedBox(height: 10),
                              const Row(
                                children: [
                                  Text(
                                    'View Details',
                                    style: TextStyle(
                                      color: _kPrimary,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: _kPrimary,
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _banner({
    required Color bg,
    required IconData icon,
    required Color iconColor,
    required String text,
    required Color textColor,
  }) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 7),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: textColor)),
        ),
      ],
    ),
  );
}

/// ─── REQUEST DETAIL ──────────────────────────────────────────────────────────
class GateRequestDetail extends StatelessWidget {
  final GateRequest request;
  const GateRequestDetail({super.key, required this.request});

  // Build action-history entries derived from status
  List<_ActionEntry> _buildHistory(GateRequest r) {
    final list = <_ActionEntry>[];
    final level = _stageIndex(r.status);

    // Always: submitted
    list.add(
      const _ActionEntry(
        actor: 'Student',
        action: 'SUBMITTED',
        note: 'Request submitted successfully',
        actionColor: _kPrimary,
        icon: Icons.send_rounded,
      ),
    );

    if (level >= 1) {
      final isDeclined = r.status == GateStatus.matronDecline;
      list.add(
        _ActionEntry(
          actor: 'Matron',
          action: isDeclined ? 'DECLINED' : 'FORWARDED',
          note: isDeclined
              ? r.matronDeclineReason ?? 'Declined by Matron'
              : 'Forwarded by Matron to RT',
          actionColor: isDeclined ? Colors.red : const Color(0xFF1565C0),
          icon: isDeclined
              ? Icons.cancel_outlined
              : Icons.forward_to_inbox_rounded,
        ),
      );
    }

    if (level >= 2 && r.status != GateStatus.matronDecline) {
      final isDeclined = r.status == GateStatus.rtDecline;
      list.add(
        _ActionEntry(
          actor: 'RT',
          action: isDeclined ? 'DECLINED' : 'FORWARDED',
          note: isDeclined
              ? r.rtDeclineReason ?? 'Declined by RT'
              : 'Forwarded by RT to Warden',
          actionColor: isDeclined ? Colors.red : const Color(0xFF1565C0),
          icon: isDeclined
              ? Icons.cancel_outlined
              : Icons.forward_to_inbox_rounded,
        ),
      );
    }

    if (level >= 3 &&
        r.status != GateStatus.matronDecline &&
        r.status != GateStatus.rtDecline) {
      final isRejected = r.status == GateStatus.wardenReject;
      final isDone = r.status == GateStatus.securityDone;
      list.add(
        _ActionEntry(
          actor: 'Warden',
          action: isRejected
              ? 'REJECTED'
              : isDone
              ? 'COMPLETED'
              : 'ACCEPTED',
          note: isRejected
              ? r.wardenRejectReason ?? 'Rejected by Warden'
              : isDone
              ? 'Completed and verified by Security'
              : 'Accepted by Warden',
          actionColor: isRejected ? Colors.red : const Color(0xFF2E7D32),
          icon: isRejected
              ? Icons.cancel_outlined
              : Icons.thumb_up_alt_outlined,
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GateRequest?>(
      stream: GateRequestService.streamSingle(request.id),
      builder: (context, snap) {
        final r = snap.data ?? request;
        final level = _stageIndex(r.status);
        final declined = _isDeclined(r.status);
        final approved =
            r.status == GateStatus.wardenAccept ||
            r.status == GateStatus.securityDone;
        final history = _buildHistory(r);

        return Scaffold(
          backgroundColor: _kBg,
          body: Column(
            children: [
              // ── Header with status badge ─────────────────────────────────
              _GradientHeader(
                title: 'Request Details',
                trailing: Container(
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
                        declined
                            ? Icons.cancel
                            : approved
                            ? Icons.check_circle
                            : Icons.hourglass_top,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        _badgeLabel(r),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Info card ──────────────────────────────────────
                      _detailCard(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_walk_rounded,
                                size: 15,
                                color: _kPrimary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                r.type,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A2E),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Room ${r.room}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF78909C),
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
                            'Complaint Message',
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

                      // Decline reason boxes
                      if (r.matronDeclineReason != null)
                        _declineBox('Matron declined', r.matronDeclineReason!),
                      if (r.rtDeclineReason != null)
                        _declineBox('RT declined', r.rtDeclineReason!),
                      if (r.wardenRejectReason != null)
                        _declineBox('Warden rejected', r.wardenRejectReason!),

                      // ── Status Tracker ────────────────────────────────
                      _detailCard(
                        children: [
                          const Text(
                            'Status Tracker',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(stages.length, (i) {
                            final isDone = i < level;
                            final isCurrent = i == level;
                            final isDeclinedStage = declined && isCurrent;
                            final isApprovedStage =
                                approved && i == stages.length - 1;
                            final isLast = i == stages.length - 1;

                            // Dot appearance
                            Color dotFill;
                            Color dotBorder;
                            IconData dotIcon;
                            Color dotIconColor;
                            double dotIconSize;

                            if (isDeclinedStage) {
                              dotFill = Colors.red.shade50;
                              dotBorder = Colors.red;
                              dotIcon = Icons.close_rounded;
                              dotIconColor = Colors.red;
                              dotIconSize = 14;
                            } else if (isDone || isApprovedStage) {
                              dotFill = const Color(0xFF2E7D32);
                              dotBorder = const Color(0xFF2E7D32);
                              dotIcon = Icons.check_rounded;
                              dotIconColor = Colors.white;
                              dotIconSize = 14;
                            } else if (isCurrent) {
                              dotFill = Colors.white;
                              dotBorder = const Color(0xFFF57F17);
                              dotIcon = Icons.circle;
                              dotIconColor = const Color(0xFFF57F17);
                              dotIconSize = 9;
                            } else {
                              dotFill = Colors.white;
                              dotBorder = const Color(0xFFCFD8DC);
                              dotIcon = Icons.circle;
                              dotIconColor = const Color(0xFFCFD8DC);
                              dotIconSize = 9;
                            }

                            return IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Timeline column
                                  SizedBox(
                                    width: 28,
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 28,
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: dotFill,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: dotBorder,
                                              width: 2,
                                            ),
                                          ),
                                          child: Icon(
                                            dotIcon,
                                            size: dotIconSize,
                                            color: dotIconColor,
                                          ),
                                        ),
                                        if (!isLast)
                                          Expanded(
                                            child: Container(
                                              width: 2,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 3,
                                                  ),
                                              color: isDone
                                                  ? const Color(0xFF2E7D32)
                                                  : const Color(0xFFE0E7F0),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  // Stage label + tag
                                  Padding(
                                    padding: EdgeInsets.only(
                                      bottom: isLast ? 0 : 18,
                                      top: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          stages[i],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color:
                                                (isDone ||
                                                    isApprovedStage ||
                                                    isCurrent)
                                                ? const Color(0xFF1A1A2E)
                                                : const Color(0xFFB0BEC5),
                                          ),
                                        ),
                                        if (isCurrent &&
                                            !declined &&
                                            !approved) ...[
                                          const SizedBox(width: 8),
                                          _stageTag(
                                            'Current',
                                            const Color(0xFFFFF8E1),
                                            const Color(0xFFF57F17),
                                          ),
                                        ],
                                        if (isDeclinedStage) ...[
                                          const SizedBox(width: 8),
                                          _stageTag(
                                            'Stopped',
                                            Colors.red.shade50,
                                            Colors.red,
                                          ),
                                        ],
                                        if (isApprovedStage) ...[
                                          const SizedBox(width: 8),
                                          _stageTag(
                                            'Approved',
                                            const Color(0xFFE8F5E9),
                                            const Color(0xFF2E7D32),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),

                      // ── Action History ────────────────────────────────
                      if (history.length > 1)
                        _detailCard(
                          children: [
                            const Text(
                              'Action History',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 14),
                            ...history.skip(1).map((e) => _historyTile(e)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stageTag(String label, Color bg, Color border) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: border),
    ),
    child: Text(
      label,
      style: TextStyle(
        fontSize: 10.5,
        color: border,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _historyTile(_ActionEntry e) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: e.actionColor.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: e.actionColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(e.icon, size: 16, color: e.actionColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${e.actor}  →  ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    e.action,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: e.actionColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                e.note,
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
  );

  Widget _detailCard({required List<Widget> children}) => Container(
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

  Widget _declineBox(String label, String reason) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFEBEE),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEF9A9A)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.info_outline, color: Colors.red, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$label: $reason',
            style: const TextStyle(color: Colors.red, fontSize: 12.5),
          ),
        ),
      ],
    ),
  );
}

// ── Action history data model ─────────────────────────────────────────────────
class _ActionEntry {
  final String actor;
  final String action;
  final String note;
  final Color actionColor;
  final IconData icon;

  const _ActionEntry({
    required this.actor,
    required this.action,
    required this.note,
    required this.actionColor,
    required this.icon,
  });
}
