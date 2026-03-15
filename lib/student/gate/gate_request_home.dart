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

bool _isDeclined(String status) {
  return status == GateStatus.matronDecline ||
      status == GateStatus.rtDecline ||
      status == GateStatus.wardenReject;
}

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

/// ===============================
/// HOME
/// ===============================
class GateRequestHome extends StatelessWidget {
  const GateRequestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Gate Request")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _option(context, "New Request", Icons.add, const GateRequestForm()),
            _option(
              context,
              "View Requests",
              Icons.list,
              const ViewGateRequests(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _option(BuildContext c, String t, IconData i, Widget page) {
    return Card(
      child: ListTile(
        leading: Icon(i),
        title: Text(t),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => page)),
      ),
    );
  }
}

/// ===============================
/// REQUEST FORM
/// ===============================
class GateRequestForm extends StatefulWidget {
  const GateRequestForm({super.key});

  @override
  State<GateRequestForm> createState() => _GateRequestFormState();
}

class _GateRequestFormState extends State<GateRequestForm> {
  final name = TextEditingController();
  final room = TextEditingController();
  final phone = TextEditingController();
  final reason = TextEditingController();

  String type = "Late Entry";
  DateTime? date;
  TimeOfDay? time;
  bool _loading = false;

  String d(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String t(TimeOfDay t) => t.format(context);

  @override
  void initState() {
    super.initState();
    name.text = StudentData.name;
    room.text = StudentData.room;
    phone.text = StudentData.phone;
  }

  @override
  void dispose() {
    name.dispose();
    room.dispose();
    phone.dispose();
    reason.dispose();
    super.dispose();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _isTooEarly(TimeOfDay picked) {
    if (date == null || !_isToday(date!)) return false;
    final now = DateTime.now();
    final pickedMinutes = picked.hour * 60 + picked.minute;
    final nowMinutes = now.hour * 60 + now.minute;
    return pickedMinutes < nowMinutes;
  }

  Future<void> _submit() async {
    if (name.text.trim().isEmpty || room.text.trim().isEmpty) {
      _snack("Name and room are required");
      return;
    }
    if (date == null || time == null) {
      _snack("Select date and time");
      return;
    }
    if (reason.text.trim().isEmpty) {
      _snack("Please enter a reason");
      return;
    }

    setState(() => _loading = true);
    try {
      final uid = Session.userId ?? '';
      await GateRequestService.submit(
        GateRequest(
          id: '',
          type: type,
          name: name.text.trim(),
          room: room.text.trim(),
          phone: phone.text.trim(),
          date: d(date!),
          time: t(time!),
          reason: reason.text.trim(),
          studentId: uid,
        ),
      );

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Success"),
          content: const Text("Request submitted successfully"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      _snack("Failed to submit: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("New Gate Request")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF90CAF9)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Details",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _infoRow("Name", name.text.isEmpty ? "—" : name.text),
                    _infoRow("Room", room.text.isEmpty ? "—" : room.text),
                    _infoRow("Phone", phone.text.isEmpty ? "—" : phone.text),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: "Request Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Late Entry",
                    child: Text("Late Entry"),
                  ),
                  DropdownMenuItem(
                    value: "Late Going",
                    child: Text("Late Going"),
                  ),
                  DropdownMenuItem(
                    value: "Early Entry",
                    child: Text("Early Entry"),
                  ),
                  DropdownMenuItem(
                    value: "Early Going",
                    child: Text("Early Going"),
                  ),
                ],
                onChanged: (v) => setState(() {
                  type = v!;
                  time = null;
                }),
              ),
              const SizedBox(height: 12),
              _tf("Name", name, readOnly: true),
              _tf("Room No", room, readOnly: true),
              TextField(
                controller: phone,
                readOnly: true,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              _pickerRow("Date", date == null ? "Pick" : d(date!), () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (p != null) {
                  setState(() {
                    date = p;
                    time = null;
                  });
                }
              }),
              const SizedBox(height: 12),
              _pickerRow("Time", time == null ? "Pick" : t(time!), date == null
                  ? null
                  : () async {
                      final initialTime = _isToday(date!)
                          ? TimeOfDay.now()
                          : const TimeOfDay(hour: 0, minute: 0);
                      final p = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (p == null || !mounted) return;
                      if (_isTooEarly(p)) {
                        _snack("Cannot select a time that has already passed");
                        return;
                      }
                      setState(() => time = p);
                    }),
              const SizedBox(height: 12),
              TextField(
                controller: reason,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Reason",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tf(
    String l,
    TextEditingController c, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _pickerRow(String l, String v, VoidCallback? onTap) {
    return Row(
      children: [
        Expanded(child: Text("$l: $v")),
        ElevatedButton(
          onPressed: onTap,
          child: Text(onTap == null ? "Select Date" : "Pick"),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
          const Text(": ", style: TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// VIEW REQUESTS (FIXED NAME DISPLAY)
/// ===============================
class ViewGateRequests extends StatelessWidget {
  const ViewGateRequests({super.key});

  Color _typeColor(String t) => t.contains("Late") ? Colors.blue : Colors.green;

  @override
  Widget build(BuildContext context) {
    final uid = Session.userId ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: StreamBuilder<List<GateRequest>>(
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
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    const Text(
                      "Could not load requests.",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${snap.error}",
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final requests = [...(snap.data ?? [])]
            ..sort((a, b) => _requestSortDateTime(b).compareTo(_requestSortDateTime(a)));
          if (requests.isEmpty) {
            return const Center(child: Text("No requests"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final r = requests[i];
              final declined = _isDeclined(r.status);
              final approved =
                  r.status == GateStatus.wardenAccept ||
                  r.status == GateStatus.securityDone;
              final badgeColor = declined
                  ? Colors.red
                  : approved
                  ? Colors.green
                  : r.status == GateStatus.pending
                  ? Colors.orange
                  : const Color(0xFF1976D2);
              final badgeText = declined
                  ? "Declined"
                  : approved
                  ? "Approved"
                  : r.status == GateStatus.pending
                  ? "Pending"
                  : "Active";

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _typeColor(r.type),
                    child: Icon(
                      declined
                          ? Icons.cancel
                          : approved
                          ? Icons.check_circle
                          : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text("${r.name} (Room ${r.room})"),
                  subtitle: Text("${r.type}\nStatus: ${r.statusLabel}"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: badgeColor),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        color: badgeColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GateRequestDetail(request: r),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===============================
/// REQUEST DETAIL (FIXED NAME)
/// ===============================
class GateRequestDetail extends StatelessWidget {
  final GateRequest request;
  const GateRequestDetail({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<GateRequest?>(
      stream: GateRequestService.streamSingle(request.id),
      builder: (context, snap) {
        final current = snap.data ?? request;
        final level = _stageIndex(current.status);
        final declined = _isDeclined(current.status);
        final approved =
            current.status == GateStatus.wardenAccept ||
            current.status == GateStatus.securityDone;

        return Scaffold(
          appBar: AppBar(title: const Text("Request Details")),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: current.statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: current.statusColor),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          declined
                              ? Icons.cancel
                              : approved
                              ? Icons.check_circle
                              : Icons.hourglass_top,
                          color: current.statusColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            current.statusLabel,
                            style: TextStyle(
                              color: current.statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Name: ${current.name}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Room: ${current.room}"),
                  Text("Phone: ${current.phone}"),
                  Text("Type: ${current.type}"),
                  Text("Date: ${current.date}"),
                  Text("Time: ${current.time}"),
                  const SizedBox(height: 12),
                  const Text(
                    "Reason",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(current.reason),
                  if (current.matronDeclineReason != null)
                    _declineBox("Matron declined", current.matronDeclineReason!),
                  if (current.rtDeclineReason != null)
                    _declineBox("RT declined", current.rtDeclineReason!),
                  if (current.wardenRejectReason != null)
                    _declineBox(
                      "Warden rejected",
                      current.wardenRejectReason!,
                    ),
                  const Divider(height: 32),
                  const Text(
                    "Status Tracker",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: List.generate(
                      stages.length,
                      (i) {
                        final isDone = i < level;
                        final isCurrent = i == level;
                        final isDeclinedStage = declined && isCurrent;
                        final isApprovedStage =
                            approved && i == stages.length - 1;

                        return ListTile(
                          leading: Icon(
                            isDeclinedStage
                                ? Icons.cancel
                                : (isDone || isApprovedStage)
                                ? Icons.check_circle
                                : isCurrent
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: isDeclinedStage
                                ? Colors.red
                                : (isDone || isApprovedStage || isCurrent)
                                ? Colors.green
                                : Colors.grey,
                          ),
                          title: Text(stages[i]),
                          subtitle: isDeclinedStage
                              ? Text(
                                  "Stopped here",
                                  style: TextStyle(
                                    color: Colors.red.shade400,
                                    fontSize: 12,
                                  ),
                                )
                              : isApprovedStage
                              ? const Text(
                                  "Approved",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 12,
                                  ),
                                )
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _declineBox(String label, String reason) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Colors.red, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                "$label: $reason",
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}