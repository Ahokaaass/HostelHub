import 'package:flutter/material.dart';
import '../student_data.dart';

// ── CONSTANTS ──────────────────────────────────────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBg = Color(0xFFF5F8FF);
const _kBorder = Color(0xFFBBD0F8);
const _kBlueTint = Color(0xFFE8F0FE);

/// ===============================
/// MODEL
/// ===============================
class Complaint {
  final String category;
  final String name;
  final String room;
  final String message;
  final String ownerId;
  int level = 0;

  Complaint({
    required this.category,
    required this.name,
    required this.room,
    required this.message,
    required this.ownerId,
  });
}

/// ===============================
/// STORAGE
/// ===============================
List<Complaint> complaints = [];

const stages = [
  "Submitted",
  "Hostel Secretary",
  "Matron",
  "RT",
  "Warden",
  "Office Admin",
];

// ── SHARED WIDGETS ─────────────────────────────────────────────────────────────

Widget _buildHeader(BuildContext context, String title,
    {String? subtitle}) {
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
                fontWeight: FontWeight.w800,
              )),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.75), fontSize: 13)),
          ]
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
            decoration:
                BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
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
    {required String label,
    required VoidCallback onPressed,
    bool loading = false}) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x441565C0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5))
          : Text(label,
              style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700)),
    ),
  );
}

/// ===============================
/// COMPLAINT HOME
/// ===============================
class ComplaintHome extends StatelessWidget {
  const ComplaintHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "Complaint",
              subtitle: "Raise or track your complaints"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildActionCard(
                    context: context,
                    icon: Icons.edit_note_rounded,
                    title: "Raise Complaint",
                    subtitle: "Submit a new complaint",
                    iconColor: _kBlue,
                    iconBg: _kBlueTint,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ComplaintForm())),
                  ),
                  const SizedBox(height: 14),
                  _buildActionCard(
                    context: context,
                    icon: Icons.list_alt_rounded,
                    title: "All Complaints",
                    subtitle: "View all submitted complaints",
                    iconColor: const Color(0xFF0277BD),
                    iconBg: const Color(0xFFE1F5FE),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ViewComplaints())),
                  ),
                  const SizedBox(height: 14),
                  _buildActionCard(
                    context: context,
                    icon: Icons.person_search_rounded,
                    title: "My Complaints",
                    subtitle: "Track your own complaints",
                    iconColor: const Color(0xFF1565C0),
                    iconBg: const Color(0xFFE8F0FE),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const MyComplaints())),
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
/// COMPLAINT FORM
/// ===============================
class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final name = TextEditingController(text: StudentData.name);
  final room = TextEditingController(text: StudentData.room);
  final message = TextEditingController();
  String category = "Room Complaint";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "Raise Complaint",
              subtitle: "Describe your issue in detail"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category dropdown
                  const Text("Category",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _kBorder, width: 1.4),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 2),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: category,
                        isExpanded: true,
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _kBlue),
                        items: const [
                          DropdownMenuItem(
                              value: "Room Complaint",
                              child: Text("Room Complaint")),
                          DropdownMenuItem(
                              value: "Mess Complaint",
                              child: Text("Mess Complaint")),
                          DropdownMenuItem(
                              value: "General Complaint",
                              child: Text("General Complaint")),
                        ],
                        onChanged: (v) => setState(() => category = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text("Name",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  TextField(
                      controller: name,
                      enabled: false,
                      decoration:
                          _inputDeco("Name", icon: Icons.person_outline_rounded)),
                  const SizedBox(height: 14),

                  const Text("Room No.",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  TextField(
                      controller: room,
                      enabled: false,
                      decoration: _inputDeco("Room No.",
                          icon: Icons.door_front_door_outlined)),
                  const SizedBox(height: 14),

                  const Text("Description",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 8),
                  TextField(
                    controller: message,
                    maxLines: 4,
                    decoration: _inputDeco("Describe your problem",
                        icon: Icons.notes_rounded),
                  ),
                  const SizedBox(height: 28),

                  _primaryButton(
                    label: "Submit Complaint",
                    onPressed: () {
                      if (message.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter all details"),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      complaints.add(Complaint(
                        category: category,
                        name: StudentData.name,
                        room: StudentData.room,
                        message: message.text,
                        ownerId: StudentData.admissionNo,
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
                          content: const Text(
                              "Complaint submitted successfully"),
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
                                      borderRadius:
                                          BorderRadius.circular(10))),
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
}

/// ===============================
/// ALL COMPLAINTS
/// ===============================
class ViewComplaints extends StatelessWidget {
  const ViewComplaints({super.key});

  Color _catColor(String c) {
    if (c == "Room Complaint") return _kBlue;
    if (c == "Mess Complaint") return const Color(0xFFF57C00);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "All Complaints",
              subtitle: "${complaints.length} complaint(s) filed"),
          Expanded(
            child: complaints.isEmpty
                ? _emptyState("No complaints yet")
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: complaints.length,
                    itemBuilder: (_, i) =>
                        _ComplaintCard(complaint: complaints[i]),
                  ),
          ),
        ],
      ),
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
    final myList = complaints
        .where((c) => c.ownerId == StudentData.admissionNo)
        .toList();

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "My Complaints",
              subtitle: "${myList.length} complaint(s)"),
          Expanded(
            child: myList.isEmpty
                ? _emptyState("You have no complaints")
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: myList.length,
                    itemBuilder: (_, i) =>
                        _ComplaintCard(complaint: myList[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// COMPLAINT CARD (shared)
/// ===============================
class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  const _ComplaintCard({required this.complaint});

  Color get _catColor {
    if (complaint.category == "Room Complaint") return _kBlue;
    if (complaint.category == "Mess Complaint")
      return const Color(0xFFF57C00);
    return const Color(0xFF2E7D32);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ComplaintDetail(complaint: complaint)),
        ),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _kBorder, width: 1.2),
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
                  color: _catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.report_problem_rounded,
                    color: _catColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(complaint.category,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text("Room ${complaint.room}",
                        style: const TextStyle(
                            fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    _StatusChip(stages[complaint.level]),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Color(0xFF6B7280)),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// COMPLAINT DETAIL
/// ===============================
class ComplaintDetail extends StatelessWidget {
  final Complaint complaint;
  const ComplaintDetail({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _buildHeader(context, "Complaint Details"),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _infoRow(
                            Icons.category_rounded, "Category",
                            complaint.category),
                        const Divider(height: 20),
                        _infoRow(
                            Icons.door_front_door_rounded, "Room",
                            complaint.room),
                        const Divider(height: 20),
                        _infoRow(Icons.notes_rounded, "Description",
                            complaint.message),
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
                        final isDone = i < complaint.level;
                        final isCurrent = i == complaint.level;
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
                                            ? Icons.radio_button_checked_rounded
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
                                          : const Color(0xFFE8F0FE)),
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
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _kBlue)),
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