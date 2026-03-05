import 'package:flutter/material.dart';

// ── CONSTANTS ──────────────────────────────────────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBg = Color(0xFFF5F8FF);
const _kBorder = Color(0xFFBBD0F8);
const _kBlueTint = Color(0xFFE8F0FE);

/// ===============================
/// MODEL
/// ===============================
class GateRequest {
  final String type;
  final String name;
  final String room;
  final String phone;
  final String date;
  final String time;
  final String reason;
  int level = 0;

  GateRequest({
    required this.type,
    required this.name,
    required this.room,
    required this.phone,
    required this.date,
    required this.time,
    required this.reason,
  });
}

/// ===============================
/// STORAGE
/// ===============================
List<GateRequest> gateRequests = [];

const stages = [
  "Submitted",
  "Matron",
  "RT",
  "Warden",
];

// ── SHARED WIDGETS ─────────────────────────────────────────────────────────────

Widget _buildHeader(BuildContext context, String title, {String? subtitle}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_kBlue, _kBlueLight],
      ),
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 13)),
          ],
        ],
      ),
    ),
  );
}

Widget _buildActionCard({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required Color iconBg,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
              color: Color(0x141565C0), blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded,
              size: 16, color: Color(0xFF6B7280)),
        ],
      ),
    ),
  );
}

InputDecoration _inputDeco(String label, {IconData? icon, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: _kBlue, fontSize: 14),
    prefixIcon: icon != null ? Icon(icon, color: _kBlue, size: 20) : null,
    suffixIcon: suffix,
    filled: true,
    fillColor: _kBlueTint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder, width: 1.4)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBlue, width: 1.8)),
    disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _kBorder, width: 1.2)),
    errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4)),
    focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.8)),
  );
}

Widget _primaryButton(
    {required String label, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x441565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
    ),
  );
}

/// ===============================
/// HOME
/// ===============================
class GateRequestHome extends StatelessWidget {
  const GateRequestHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "Gate Request",
              subtitle: "Manage entry & exit requests"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.add_circle_outline_rounded,
                    title: "New Request",
                    subtitle: "Submit a gate entry/exit request",
                    iconColor: _kBlue,
                    iconBg: _kBlueTint,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GateRequestForm()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildActionCard(
                    context: context,
                    icon: Icons.list_alt_rounded,
                    title: "View Requests",
                    subtitle: "Track all your submitted requests",
                    iconColor: const Color(0xFF0277BD),
                    iconBg: const Color(0xFFE1F5FE),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ViewGateRequests()),
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

  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String _fmtTime(TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "New Gate Request",
              subtitle: "Fill in the details below"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Request Type
                  _fieldLabel("Request Type"),
                  const SizedBox(height: 8),
                  _styledDropdown<String>(
                    value: type,
                    items: const [
                      "Late Entry",
                      "Late Going",
                      "Early Entry",
                      "Early Going"
                    ],
                    onChanged: (v) => setState(() => type = v!),
                  ),
                  const SizedBox(height: 14),

                  _fieldLabel("Name"),
                  const SizedBox(height: 8),
                  TextField(
                      controller: name,
                      decoration:
                          _inputDeco("Full name", icon: Icons.person_outline_rounded)),
                  const SizedBox(height: 14),

                  _fieldLabel("Room No."),
                  const SizedBox(height: 8),
                  TextField(
                      controller: room,
                      decoration: _inputDeco("Room number",
                          icon: Icons.door_front_door_outlined)),
                  const SizedBox(height: 14),

                  _fieldLabel("Phone Number"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    decoration:
                        _inputDeco("Phone", icon: Icons.phone_outlined),
                  ),
                  const SizedBox(height: 14),

                  // Date & Time pickers
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: "Date",
                          value: date == null ? "Pick date" : _fmtDate(date!),
                          onTap: () async {
                            final p = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: _kBlue),
                                ),
                                child: child!,
                              ),
                            );
                            if (p != null) setState(() => date = p);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.access_time_rounded,
                          label: "Time",
                          value: time == null ? "Pick time" : _fmtTime(time!),
                          onTap: () async {
                            final p = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.now(),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: _kBlue),
                                ),
                                child: child!,
                              ),
                            );
                            if (p != null) setState(() => time = p);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _fieldLabel("Reason"),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reason,
                    maxLines: 3,
                    decoration: _inputDeco("State your reason",
                        icon: Icons.notes_rounded),
                  ),
                  const SizedBox(height: 28),

                  _primaryButton(
                    label: "Submit Request",
                    onPressed: () {
                      if (date == null || time == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please select date and time"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      gateRequests.add(GateRequest(
                        type: type,
                        name: name.text,
                        room: room.text,
                        phone: phone.text,
                        date: _fmtDate(date!),
                        time: _fmtTime(time!),
                        reason: reason.text,
                      ));
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          title: Row(
                            children: const [
                              Icon(Icons.check_circle_rounded,
                                  color: _kBlue),
                              SizedBox(width: 8),
                              Text("Success"),
                            ],
                          ),
                          content: const Text("Request submitted successfully"),
                          actions: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _kBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Text(
        label,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E)),
      );

  Widget _styledDropdown<T>({
    required T value,
    required List<String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _kBlueTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder, width: 1.4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: _kBlue),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item as T,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// ===============================
/// VIEW REQUESTS
/// ===============================
class ViewGateRequests extends StatelessWidget {
  const ViewGateRequests({super.key});

  Color _typeColor(String t) =>
      t.contains("Late") ? _kBlue : const Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "My Requests",
              subtitle: "${gateRequests.length} request(s)"),
          Expanded(
            child: gateRequests.isEmpty
                ? _emptyState("No requests submitted yet")
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: gateRequests.length,
                    itemBuilder: (_, i) {
                      final r = gateRequests[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    GateRequestDetail(request: r)),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: _kBorder, width: 1.2),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0F1565C0),
                                    blurRadius: 8,
                                    offset: Offset(0, 3))
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _typeColor(r.type)
                                        .withOpacity(0.12),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    r.type.contains("Entry")
                                        ? Icons.login_rounded
                                        : Icons.logout_rounded,
                                    color: _typeColor(r.type),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(r.type,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                              color: Color(0xFF1A1A2E))),
                                      const SizedBox(height: 2),
                                      Text(
                                          "${r.name}  •  Room ${r.room}",
                                          style: const TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF6B7280))),
                                      const SizedBox(height: 6),
                                      _StatusChip(stages[r.level]),
                                    ],
                                  ),
                                ),
                                const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: Color(0xFF6B7280)),
                              ],
                            ),
                          ),
                        ),
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
/// REQUEST DETAIL
/// ===============================
class GateRequestDetail extends StatelessWidget {
  final GateRequest request;
  const GateRequestDetail({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "Request Details"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x141565C0),
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      children: [
                        _infoRow(Icons.swap_horiz_rounded, "Type",
                            request.type),
                        const Divider(height: 20),
                        _infoRow(Icons.person_outline_rounded, "Name",
                            request.name),
                        const Divider(height: 20),
                        _infoRow(
                            Icons.door_front_door_outlined,
                            "Room",
                            request.room),
                        const Divider(height: 20),
                        _infoRow(Icons.phone_outlined, "Phone",
                            request.phone),
                        const Divider(height: 20),
                        _infoRow(Icons.calendar_today_rounded, "Date",
                            request.date),
                        const Divider(height: 20),
                        _infoRow(Icons.access_time_rounded, "Time",
                            request.time),
                        const Divider(height: 20),
                        _infoRow(Icons.notes_rounded, "Reason",
                            request.reason),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text("Status Tracker",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder, width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x141565C0),
                            blurRadius: 10,
                            offset: Offset(0, 3))
                      ],
                    ),
                    child: Column(
                      children: List.generate(stages.length, (i) {
                        final isDone = i < request.level;
                        final isCurrent = i == request.level;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: isDone || isCurrent
                                        ? _kBlue
                                        : const Color(0xFFE8F0FE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isDone
                                        ? Icons.check_rounded
                                        : isCurrent
                                            ? Icons
                                                .radio_button_checked_rounded
                                            : Icons.circle_outlined,
                                    size: 16,
                                    color: isDone || isCurrent
                                        ? Colors.white
                                        : const Color(0xFFBBD0F8),
                                  ),
                                ),
                                if (i < stages.length - 1)
                                  Container(
                                    width: 2,
                                    height: 28,
                                    color: isDone
                                        ? _kBlue
                                        : const Color(0xFFE8F0FE),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                stages[i],
                                style: TextStyle(
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: isDone || isCurrent
                                      ? const Color(0xFF1A1A2E)
                                      : const Color(0xFF9CA3AF),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
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

  static Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
              color: _kBlueTint, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: _kBlue, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280))),
              const SizedBox(height: 2),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1A1A2E))),
            ],
          ),
        ),
      ],
    );
  }
}

// ── HELPER WIDGETS ─────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  const _StatusChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: _kBlueTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kBorder),
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _kBlue)),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _kBlueTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder, width: 1.4),
        ),
        child: Row(
          children: [
            Icon(icon, color: _kBlue, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF6B7280))),
                  Text(value,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: Color(0xFF1A1A2E))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _emptyState(String msg) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.inbox_rounded, size: 56, color: _kBorder),
        const SizedBox(height: 12),
        Text(msg,
            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 15)),
      ],
    ),
  );
}