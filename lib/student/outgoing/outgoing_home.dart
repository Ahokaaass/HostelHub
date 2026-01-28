import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../student_data.dart';

/// ===============================
/// MODEL
/// ===============================
class OutgoingRecord {
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
}

/// ===============================
/// LOCAL STORAGE (UNCHANGED)
/// ===============================
List<OutgoingRecord> outgoingList = [];
List<OutgoingRecord> homeGoingList = [];
List<OutgoingRecord> hospitalGoingList = [];

/// ===============================
/// FIRESTORE SYNC (NEW)
/// ===============================
Future<void> loadOutgoingFromFirestore() async {
  outgoingList.clear();
  homeGoingList.clear();
  hospitalGoingList.clear();

  final snap =
      await FirebaseFirestore.instance.collection('outgoing').get();

  for (var d in snap.docs) {
    final data = d.data();

    final record = OutgoingRecord(
      type: data['type'],
      name: data['name'],
      room: data['room'],
      place: data['place'],
      outDate: data['outDate'],
      outTime: data['outTime'],
      ownerId: data['studentId'],
      returnDate: data['returnDate'],
      returnTime: data['returnTime'],
    );

    if (record.type == "Outgoing") outgoingList.add(record);
    if (record.type == "Home Going") homeGoingList.add(record);
    if (record.type == "Hospital Going") hospitalGoingList.add(record);
  }
}

/// ===============================
/// OUTGOING HOME
/// ===============================
class OutgoingHome extends StatelessWidget {
  const OutgoingHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Outgoing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _option(context, "Add Outgoing", Icons.add, const OutgoingForm()),
            _option(
              context,
              "View Records",
              Icons.list,
              const RecordCategoryPage(),
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
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () async {
          await loadOutgoingFromFirestore(); // ✅ LOAD BEFORE VIEW
          Navigator.push(
            c,
            MaterialPageRoute(builder: (_) => page),
          );
        },
      ),
    );
  }
}

/// ===============================
/// ADD OUTGOING FORM
/// ===============================
class OutgoingForm extends StatefulWidget {
  const OutgoingForm({super.key});

  @override
  State<OutgoingForm> createState() => _OutgoingFormState();
}

class _OutgoingFormState extends State<OutgoingForm> {
  final name = TextEditingController(text: StudentData.name);
  final room = TextEditingController(text: StudentData.room);
  final place = TextEditingController();

  String? type;
  DateTime? outDate;
  TimeOfDay? outTime;

  String d(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String t(TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Outgoing")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                hint: const Text("Select Type"),
                value: type,
                items: const [
                  DropdownMenuItem(value: "Outgoing", child: Text("Outgoing")),
                  DropdownMenuItem(
                      value: "Home Going", child: Text("Home Going")),
                  DropdownMenuItem(
                      value: "Hospital Going",
                      child: Text("Hospital Going")),
                ],
                onChanged: (v) => setState(() => type = v),
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),

              const SizedBox(height: 12),
              _tf("Name", name, enabled: false),
              _tf("Room No", room, enabled: false),
              _tf("Place", place),

              const SizedBox(height: 16),

              _picker("Out Time",
                  outTime == null ? "Pick" : t(outTime!), () async {
                final p = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (p != null) setState(() => outTime = p);
              }),

              const SizedBox(height: 12),

              _picker("Out Date",
                  outDate == null ? "Pick" : d(outDate!), () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );
                if (p != null) setState(() => outDate = p);
              }),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () async {
                  if (type == null ||
                      outDate == null ||
                      outTime == null ||
                      place.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter all details"),
                      ),
                    );
                    return;
                  }

                  final record = OutgoingRecord(
                    type: type!,
                    name: name.text,
                    room: room.text,
                    place: place.text,
                    outDate: d(outDate!),
                    outTime: t(outTime!),
                    ownerId: StudentData.admissionNo,
                  );

                  await FirebaseFirestore.instance
                      .collection('outgoing')
                      .add({
                    "studentId": record.ownerId,
                    "type": record.type,
                    "name": record.name,
                    "room": record.room,
                    "place": record.place,
                    "outDate": record.outDate,
                    "outTime": record.outTime,
                    "returnDate": null,
                    "returnTime": null,
                    "createdAt": FieldValue.serverTimestamp(),
                  });

                  Navigator.pop(context);
                },
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tf(String l, TextEditingController c, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration:
            InputDecoration(labelText: l, border: const OutlineInputBorder()),
      ),
    );
  }

  Widget _picker(String l, String v, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(child: Text("$l: $v")),
        ElevatedButton(onPressed: onTap, child: const Text("Pick")),
      ],
    );
  }
}

/// ===============================
/// RECORD CATEGORY PAGE (UNCHANGED)
/// ===============================
class RecordCategoryPage extends StatelessWidget {
  const RecordCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Outgoing Records")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _opt(context, "Outgoing Records", outgoingList),
            _opt(context, "Home Going Records", homeGoingList),
            _opt(context, "Hospital Going Records", hospitalGoingList),
          ],
        ),
      ),
    );
  }

  Widget _opt(BuildContext c, String t, List<OutgoingRecord> list) {
    return Card(
      child: ListTile(
        title: Text(t),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            c,
            MaterialPageRoute(
              builder: (_) => RecordListPage(title: t, records: list),
            ),
          );
        },
      ),
    );
  }
}

/// ===============================
/// RECORD LIST PAGE (OWNER CHECK OK)
/// ===============================
class RecordListPage extends StatefulWidget {
  final String title;
  final List<OutgoingRecord> records;

  const RecordListPage({super.key, required this.title, required this.records});

  @override
  State<RecordListPage> createState() => _RecordListPageState();
}

class _RecordListPageState extends State<RecordListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: widget.records.isEmpty
          ? const Center(child: Text("No records"))
          : ListView.builder(
              itemCount: widget.records.length,
              itemBuilder: (_, i) {
                final r = widget.records[i];
                final isOwner =
                    r.ownerId == StudentData.admissionNo;

                return Card(
                  child: ListTile(
                    title: Text("${r.name} (Room ${r.room})"),
                    subtitle: Text(
                      "${r.place}\nOut: ${r.outDate} • ${r.outTime}\n"
                      "${r.returnDate == null
                          ? "Return: Not updated"
                          : "Return: ${r.returnDate} • ${r.returnTime}"}",
                    ),
                    trailing: (!isOwner || r.returnDate != null)
                        ? null
                        : const Icon(Icons.edit),
                    onTap: (!isOwner || r.returnDate != null)
                        ? null
                        : () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    UpdateReturnPage(record: r),
                              ),
                            );
                            setState(() {});
                          },
                  ),
                );
              },
            ),
    );
  }
}

/// ===============================
/// UPDATE RETURN PAGE (FIRESTORE SAFE)
/// ===============================
class UpdateReturnPage extends StatefulWidget {
  final OutgoingRecord record;
  const UpdateReturnPage({super.key, required this.record});

  @override
  State<UpdateReturnPage> createState() => _UpdateReturnPageState();
}

class _UpdateReturnPageState extends State<UpdateReturnPage> {
  DateTime? rDate;
  TimeOfDay? rTime;

  String d(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String t(TimeOfDay t) => t.format(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Return")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row("Return Time",
                rTime == null ? "Pick" : t(rTime!), () async {
              final p = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (p != null) setState(() => rTime = p);
            }),
            const SizedBox(height: 12),
            _row("Return Date",
                rDate == null ? "Pick" : d(rDate!), () async {
              final p = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2023),
                lastDate: DateTime(2030),
              );
              if (p != null) setState(() => rDate = p);
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (rDate == null || rTime == null) return;

                widget.record.returnDate = d(rDate!);
                widget.record.returnTime = t(rTime!);

                final q = await FirebaseFirestore.instance
                    .collection('outgoing')
                    .where('studentId',
                        isEqualTo: widget.record.ownerId)
                    .where('outDate',
                        isEqualTo: widget.record.outDate)
                    .where('outTime',
                        isEqualTo: widget.record.outTime)
                    .limit(1)
                    .get();

                if (q.docs.isNotEmpty) {
                  await q.docs.first.reference.update({
                    "returnDate": widget.record.returnDate,
                    "returnTime": widget.record.returnTime,
                  });
                }

                Navigator.pop(context);
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String l, String v, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(child: Text("$l: $v")),
        ElevatedButton(onPressed: onTap, child: const Text("Pick")),
      ],
    );
  }
}
