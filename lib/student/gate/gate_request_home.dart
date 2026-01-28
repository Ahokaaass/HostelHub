import 'package:flutter/material.dart';

/// ===============================
/// MODEL
/// ===============================
class GateRequest {
  final String type; // Late Entry, Late Going, Early Entry, Early Going
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
            _option(context, "View Requests", Icons.list, const ViewGateRequests()),
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

  String d(DateTime d) => "${d.day}/${d.month}/${d.year}";
  String t(TimeOfDay t) => t.format(context);

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
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(
                  labelText: "Request Type",
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: "Late Entry", child: Text("Late Entry")),
                  DropdownMenuItem(value: "Late Going", child: Text("Late Going")),
                  DropdownMenuItem(value: "Early Entry", child: Text("Early Entry")),
                  DropdownMenuItem(value: "Early Going", child: Text("Early Going")),
                ],
                onChanged: (v) => setState(() => type = v!),
              ),

              const SizedBox(height: 12),
              _tf("Name", name),
              _tf("Room No", room),

              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 12),

              _pickerRow(
                "Date",
                date == null ? "Pick" : d(date!),
                () async {
                  final p = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (p != null) setState(() => date = p);
                },
              ),

              _pickerRow(
                "Time",
                time == null ? "Pick" : t(time!),
                () async {
                  final p = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (p != null) setState(() => time = p);
                },
              ),

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
                  onPressed: () {
                    if (date == null || time == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Select date and time")),
                      );
                      return;
                    }

                    gateRequests.add(
                      GateRequest(
                        type: type,
                        name: name.text,
                        room: room.text,
                        phone: phone.text,
                        date: d(date!),
                        time: t(time!),
                        reason: reason.text,
                      ),
                    );

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Success"),
                        content:
                            const Text("Request submitted successfully"),
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
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tf(String l, TextEditingController c) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: c,
          decoration:
              InputDecoration(labelText: l, border: const OutlineInputBorder()),
        ),
      );

  Widget _pickerRow(String l, String v, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(child: Text("$l: $v")),
        ElevatedButton(onPressed: onTap, child: const Text("Pick")),
      ],
    );
  }
}

/// ===============================
/// VIEW REQUESTS (FIXED NAME DISPLAY)
/// ===============================
class ViewGateRequests extends StatelessWidget {
  const ViewGateRequests({super.key});

  Color _typeColor(String t) =>
      t.contains("Late") ? Colors.blue : Colors.green;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Requests")),
      body: gateRequests.isEmpty
          ? const Center(child: Text("No requests"))
          : ListView.builder(
              itemCount: gateRequests.length,
              itemBuilder: (_, i) {
                final r = gateRequests[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _typeColor(r.type),
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text("${r.name} (Room ${r.room})"),
                    subtitle: Text("${r.type}\nStatus: ${stages[r.level]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
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
    return Scaffold(
      appBar: AppBar(title: const Text("Request Details")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Name: ${request.name}",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Room: ${request.room}"),
              Text("Phone: ${request.phone}"),
              Text("Type: ${request.type}"),
              Text("Date: ${request.date}"),
              Text("Time: ${request.time}"),

              const SizedBox(height: 12),
              const Text("Reason",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text(request.reason),

              const Divider(height: 32),
              const Text(
                "Status Tracker",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Column(
                children: List.generate(
                  stages.length,
                  (i) => ListTile(
                    leading: Icon(
                      i < request.level
                          ? Icons.check_circle
                          : i == request.level
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                      color:
                          i <= request.level ? Colors.green : Colors.grey,
                    ),
                    title: Text(stages[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
