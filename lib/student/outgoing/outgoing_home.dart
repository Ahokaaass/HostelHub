import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_data.dart';

// ── THEME CONSTANTS ────────────────────────────────────────────────────────────
const _kBlue = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBg = Color(0xFFF5F8FF);
const _kBorder = Color(0xFFBBD0F8);
const _kBlueTint = Color(0xFFE8F0FE);

// ─────────────────────────────────────────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────────────────────────────────────────
class OutgoingRecord {
  final String docId; // Firestore doc ID — used for direct updates
  final String type;
  final String name;
  final String room;
  final String place;
  final String outDate;
  final String outTime;
  final String ownerId;
  String? returnDate;
  String? returnTime;

  OutgoingRecord({
    required this.docId,
    required this.type,
    required this.name,
    required this.room,
    required this.place,
    required this.outDate,
    required this.outTime,
    required this.ownerId,
    this.returnDate,
    this.returnTime,
  });

  factory OutgoingRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OutgoingRecord(
      docId: doc.id,
      type: data['type'] ?? '',
      name: data['name'] ?? '',
      room: data['room'] ?? '',
      place: data['place'] ?? '',
      outDate: data['outDate'] ?? '',
      outTime: data['outTime'] ?? '',
      ownerId: data['studentId'] ?? '',
      returnDate: data['returnDate'],
      returnTime: data['returnTime'],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED UI HELPERS
// ─────────────────────────────────────────────────────────────────────────────

Widget _header(BuildContext ctx, String title, {String? subtitle}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
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
            onTap: () => Navigator.pop(ctx),
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
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: TextStyle(
                    color: Colors.white.withOpacity(0.78), fontSize: 13)),
          ],
        ],
      ),
    ),
  );
}

Widget _primaryBtn(String label, VoidCallback onPressed,
    {bool loading = false}) {
  return SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _kBlue,
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0x441565C0),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

InputDecoration _inputDeco(String label, {IconData? icon}) => InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: _kBlue, fontSize: 14),
      prefixIcon: icon != null ? Icon(icon, color: _kBlue, size: 20) : null,
      filled: true,
      fillColor: _kBlueTint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.4)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Colors.redAccent, width: 1.8)),
    );

Widget _fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E))),
    );

Widget _actionCard(
    BuildContext ctx,
    IconData icon,
    Color iconColor,
    Color iconBg,
    String title,
    String sub,
    VoidCallback onTap) {
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
                Text(sub,
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

Widget _emptyState(String msg) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.inbox_rounded, size: 60, color: _kBorder),
          const SizedBox(height: 14),
          Text(msg,
              style: const TextStyle(
                  color: Color(0xFF6B7280), fontSize: 15)),
        ],
      ),
    );

// ─────────────────────────────────────────────────────────────────────────────
// PICKER TILE
// ─────────────────────────────────────────────────────────────────────────────
class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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

// ─────────────────────────────────────────────────────────────────────────────
// OUTGOING HOME
// ─────────────────────────────────────────────────────────────────────────────
class OutgoingHome extends StatelessWidget {
  const OutgoingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _header(context, "Outgoing",
              subtitle: "Manage your outgoing records"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _actionCard(
                    context,
                    Icons.add_circle_outline_rounded,
                    _kBlue,
                    _kBlueTint,
                    "Add Outgoing",
                    "Record a new outgoing entry",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OutgoingForm()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _actionCard(
                    context,
                    Icons.list_alt_rounded,
                    const Color(0xFF0277BD),
                    const Color(0xFFE1F5FE),
                    "View Records",
                    "Browse all outgoing records by category",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecordCategoryPage()),
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

// ─────────────────────────────────────────────────────────────────────────────
// ADD OUTGOING FORM
// ─────────────────────────────────────────────────────────────────────────────
class OutgoingForm extends StatefulWidget {
  const OutgoingForm({super.key});

  @override
  State<OutgoingForm> createState() => _OutgoingFormState();
}

class _OutgoingFormState extends State<OutgoingForm> {
  // Pre-filled and locked — same as old file
  late final TextEditingController _name =
      TextEditingController(text: StudentData.name);
  late final TextEditingController _room =
      TextEditingController(text: StudentData.room);
  final TextEditingController _place = TextEditingController();

  String? _type;
  DateTime? _outDate;
  TimeOfDay? _outTime;
  bool _submitting = false;

  // Only today and future allowed
  final DateTime _today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String _fmtTime(TimeOfDay t) => t.format(context);

  @override
  void dispose() {
    _name.dispose();
    _room.dispose();
    _place.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _today, // ✅ no past dates
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kBlue)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _outDate = p);
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final p = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kBlue)),
        child: child!,
      ),
    );
    if (p == null) return;

    // ✅ If today, block past times
    if (_outDate != null &&
        _outDate!.year == _today.year &&
        _outDate!.month == _today.month &&
        _outDate!.day == _today.day) {
      final picked = p.hour * 60 + p.minute;
      final nowMins = now.hour * 60 + now.minute;
      if (picked < nowMins) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot select a past time for today"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    }
    setState(() => _outTime = p);
  }

  Future<void> _submit() async {
    if (_type == null ||
        _outDate == null ||
        _outTime == null ||
        _place.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all details"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await FirebaseFirestore.instance.collection('outgoing').add({
        "studentId": StudentData.admissionNo,
        "type": _type,
        "name": _name.text,
        "room": _room.text,
        "place": _place.text.trim(),
        "outDate": _fmtDate(_outDate!),
        "outTime": _fmtTime(_outTime!),
        "returnDate": null,
        "returnTime": null,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle_rounded, color: _kBlue),
            SizedBox(width: 8),
            Text("Submitted!")
          ]),
          content: Text(
              "$_type record added.\nDate: ${_fmtDate(_outDate!)}  •  Time: ${_fmtTime(_outTime!)}"),
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
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _header(context, "Add Outgoing",
              subtitle: "Fill in your departure details"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── TYPE ─────────────────────────────────────────────────
                  _fieldLabel("Outgoing Type"),
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
                        value: _type,
                        isExpanded: true,
                        hint: const Text("Select type",
                            style: TextStyle(
                                color: Color(0xFF6B7280), fontSize: 14)),
                        icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: _kBlue),
                        items: const [
                          DropdownMenuItem(
                              value: "Outgoing",
                              child: Text("Outgoing")),
                          DropdownMenuItem(
                              value: "Home Going",
                              child: Text("Home Going")),
                          DropdownMenuItem(
                              value: "Hospital Going",
                              child: Text("Hospital Going")),
                        ],
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── NAME (prefilled + locked) ─────────────────────────
                  _fieldLabel("Name"),
                  TextField(
                      controller: _name,
                      enabled: false,
                      decoration: _inputDeco("Name",
                          icon: Icons.person_outline_rounded)),
                  const SizedBox(height: 16),

                  // ── ROOM (prefilled + locked) ─────────────────────────
                  _fieldLabel("Room No."),
                  TextField(
                      controller: _room,
                      enabled: false,
                      decoration: _inputDeco("Room number",
                          icon: Icons.door_front_door_outlined)),
                  const SizedBox(height: 16),

                  // ── PLACE ────────────────────────────────────────────
                  _fieldLabel("Destination / Place"),
                  TextField(
                      controller: _place,
                      decoration: _inputDeco("Where are you going?",
                          icon: Icons.location_on_outlined)),
                  const SizedBox(height: 18),

                  // ── DATE then TIME ────────────────────────────────────
                  _fieldLabel("Out Date & Time"),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: "Out Date",
                          value: _outDate == null
                              ? "Tap to pick"
                              : _fmtDate(_outDate!),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.access_time_rounded,
                          label: "Out Time",
                          value: _outTime == null
                              ? "Pick date first"
                              : _fmtTime(_outTime!),
                          onTap: _outDate == null
                              ? () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Pick date first"),
                                    backgroundColor: Colors.redAccent,
                                  ))
                              : _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  _primaryBtn("Submit Outgoing", _submit,
                      loading: _submitting),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RECORD CATEGORY PAGE
// ─────────────────────────────────────────────────────────────────────────────
class RecordCategoryPage extends StatelessWidget {
  const RecordCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _header(context, "Outgoing Records",
              subtitle: "Choose a category to view"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _actionCard(
                    context,
                    Icons.arrow_outward_rounded,
                    _kBlue,
                    _kBlueTint,
                    "Outgoing",
                    "Regular outgoing records",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecordListPage(
                              title: "Outgoing Records",
                              filterType: "Outgoing")),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _actionCard(
                    context,
                    Icons.home_outlined,
                    const Color(0xFF2E7D32),
                    const Color(0xFFE8F5E9),
                    "Home Going",
                    "Students who went home",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecordListPage(
                              title: "Home Going Records",
                              filterType: "Home Going")),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _actionCard(
                    context,
                    Icons.local_hospital_outlined,
                    const Color(0xFFC62828),
                    const Color(0xFFFFEBEE),
                    "Hospital Going",
                    "Students who went to hospital",
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RecordListPage(
                              title: "Hospital Going Records",
                              filterType: "Hospital Going")),
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

// ─────────────────────────────────────────────────────────────────────────────
// RECORD LIST PAGE  — real-time Firestore stream filtered by type
// ─────────────────────────────────────────────────────────────────────────────
class RecordListPage extends StatelessWidget {
  final String title;
  final String filterType;

  const RecordListPage(
      {super.key, required this.title, required this.filterType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _header(context, title, subtitle: "Live records from database"),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('outgoing')
                  .where('type', isEqualTo: filterType)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style:
                              const TextStyle(color: Colors.redAccent)));
                }
                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return _emptyState("No $filterType records found");
                }

                final records = snapshot.data!.docs
                    .map((d) => OutgoingRecord.fromFirestore(d))
                    .toList();

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: records.length,
                  itemBuilder: (_, i) {
                    final r = records[i];
                    final isOwner =
                        r.ownerId == StudentData.admissionNo;
                    final hasReturn = r.returnDate != null;

                    return _RecordCard(
                      record: r,
                      isOwner: isOwner,
                      hasReturn: hasReturn,
                      onUpdateTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                UpdateReturnPage(record: r)),
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
}

// ─────────────────────────────────────────────────────────────────────────────
// RECORD CARD
// ─────────────────────────────────────────────────────────────────────────────
class _RecordCard extends StatelessWidget {
  final OutgoingRecord record;
  final bool isOwner;
  final bool hasReturn;
  final VoidCallback onUpdateTap;

  const _RecordCard({
    required this.record,
    required this.isOwner,
    required this.hasReturn,
    required this.onUpdateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color: Color(0x0F1565C0),
                blurRadius: 10,
                offset: Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: _kBlueTint,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_outline_rounded,
                      color: _kBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E))),
                      Text("Room ${record.room}  •  ${record.place}",
                          style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
                // ✅ Only owner, only if return not added yet
                if (isOwner && !hasReturn)
                  GestureDetector(
                    onTap: onUpdateTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kBlueTint,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Text("Add Return",
                          style: TextStyle(
                              fontSize: 12,
                              color: _kBlue,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                if (hasReturn)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Text("Returned",
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _infoChip(
                    Icons.login_rounded,
                    "Departed",
                    record.outDate,
                    record.outTime,
                    _kBlueTint,
                    _kBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoChip(
                    Icons.logout_rounded,
                    "Return",
                    hasReturn ? record.returnDate! : "—",
                    hasReturn ? record.returnTime! : "Not yet updated",
                    hasReturn
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    hasReturn
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoChip(IconData icon, String heading, String line1,
      String line2, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading,
                    style: TextStyle(
                        fontSize: 10,
                        color: color.withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
                Text(line1,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text(line2,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE RETURN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class UpdateReturnPage extends StatefulWidget {
  final OutgoingRecord record;
  const UpdateReturnPage({super.key, required this.record});

  @override
  State<UpdateReturnPage> createState() => _UpdateReturnPageState();
}

class _UpdateReturnPageState extends State<UpdateReturnPage> {
  DateTime? _rDate;
  TimeOfDay? _rTime;
  bool _saving = false;

  final DateTime _today = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _fmtDate(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String _fmtTime(TimeOfDay t) => t.format(context);

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: _today, // ✅ no past dates
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kBlue)),
        child: child!,
      ),
    );
    if (p != null) setState(() => _rDate = p);
  }

  Future<void> _pickTime() async {
    final now = TimeOfDay.now();
    final p = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
            colorScheme: const ColorScheme.light(primary: _kBlue)),
        child: child!,
      ),
    );
    if (p == null) return;

    // ✅ Block past times if today is chosen
    if (_rDate != null &&
        _rDate!.year == _today.year &&
        _rDate!.month == _today.month &&
        _rDate!.day == _today.day) {
      final picked = p.hour * 60 + p.minute;
      final nowMins = now.hour * 60 + now.minute;
      if (picked < nowMins) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Cannot select a past time"),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }
    }
    setState(() => _rTime = p);
  }

  Future<void> _save() async {
    if (_rDate == null || _rTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please pick both date and time"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      // ✅ Update by docId — reliable, no query matching issues
      await FirebaseFirestore.instance
          .collection('outgoing')
          .doc(widget.record.docId)
          .update({
        "returnDate": _fmtDate(_rDate!),
        "returnTime": _fmtTime(_rTime!),
      });

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.check_circle_rounded, color: _kBlue),
            SizedBox(width: 8),
            Text("Return Updated!")
          ]),
          content: Text(
              "Return recorded:\n${_fmtDate(_rDate!)}  •  ${_fmtTime(_rTime!)}"),
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
                      borderRadius: BorderRadius.circular(10))),
              child: const Text("Done"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          _header(context, "Update Return",
              subtitle: "Record your return to the hostel"),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card of original outgoing
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Outgoing Summary",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B7280))),
                        const SizedBox(height: 10),
                        _summaryRow(Icons.swap_horiz_rounded, "Type",
                            widget.record.type),
                        const SizedBox(height: 6),
                        _summaryRow(Icons.location_on_outlined, "Place",
                            widget.record.place),
                        const SizedBox(height: 6),
                        _summaryRow(
                            Icons.login_rounded,
                            "Departed",
                            "${widget.record.outDate}  •  ${widget.record.outTime}"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  _fieldLabel("Return Date & Time"),
                  Row(
                    children: [
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.calendar_today_rounded,
                          label: "Return Date",
                          value: _rDate == null
                              ? "Tap to pick"
                              : _fmtDate(_rDate!),
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PickerTile(
                          icon: Icons.access_time_rounded,
                          label: "Return Time",
                          value: _rTime == null
                              ? "Pick date first"
                              : _fmtTime(_rTime!),
                          onTap: _rDate == null
                              ? () => ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text("Pick date first"),
                                    backgroundColor: Colors.redAccent,
                                  ))
                              : _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _primaryBtn("Confirm Return", _save, loading: _saving),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: _kBlue),
        const SizedBox(width: 8),
        Text("$label: ",
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF6B7280))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
        ),
      ],
    );
  }
}