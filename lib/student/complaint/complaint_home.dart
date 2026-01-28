import 'package:flutter/material.dart';
import '../student_data.dart';

/// ===============================
/// MODEL
/// ===============================
class Complaint {
  final String category;
  final String name;
  final String room;
  final String message;
  final String ownerId; // admission no

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

/// ===============================
/// COMPLAINT HOME
/// ===============================
class ComplaintHome extends StatelessWidget {
  const ComplaintHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaint")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _option(context, "Raise Complaint", Icons.edit, const ComplaintForm()),
            _option(context, "All Complaints", Icons.list, const ViewComplaints()),
            _option(
              context,
              "My Complaints",
              Icons.person,
              const MyComplaints(),
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
/// COMPLAINT FORM
/// ===============================
class ComplaintForm extends StatefulWidget {
  const ComplaintForm({super.key});

  @override
  State<ComplaintForm> createState() => _ComplaintFormState();
}

class _ComplaintFormState extends State<ComplaintForm> {
  final name =
      TextEditingController(text: StudentData.name); // auto
  final room =
      TextEditingController(text: StudentData.room); // auto
  final message = TextEditingController();

  String category = "Room Complaint";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Raise Complaint")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                labelText: "Complaint Category",
                border: OutlineInputBorder(),
              ),
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
            const SizedBox(height: 12),

            _tf("Name", name, enabled: false),
            _tf("Room No", room, enabled: false),

            TextField(
              controller: message,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Describe your problem",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (message.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter all details"),
                      ),
                    );
                    return;
                  }

                  complaints.add(
                    Complaint(
                      category: category,
                      name: StudentData.name,
                      room: StudentData.room,
                      message: message.text,
                      ownerId: StudentData.admissionNo,
                    ),
                  );

                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Success"),
                      content:
                          const Text("Complaint submitted successfully"),
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
    );
  }

  Widget _tf(String l, TextEditingController c,
      {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: l,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// ===============================
/// ALL COMPLAINTS
/// ===============================
class ViewComplaints extends StatelessWidget {
  const ViewComplaints({super.key});

  Color _color(String c) {
    if (c == "Room Complaint") return Colors.blue;
    if (c == "Mess Complaint") return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Complaints")),
      body: complaints.isEmpty
          ? const Center(child: Text("No complaints"))
          : ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (_, i) {
                final c = complaints[i];
                return _tile(context, c);
              },
            ),
    );
  }

  Widget _tile(BuildContext context, Complaint c) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color(c.category),
          child: const Icon(Icons.report, color: Colors.white),
        ),
        title: Text("${c.category} (Room ${c.room})"),
        subtitle: Text("Status: ${stages[c.level]}"),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ComplaintDetail(complaint: c),
            ),
          );
        },
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
      appBar: AppBar(title: const Text("My Complaints")),
      body: myList.isEmpty
          ? const Center(child: Text("No complaints"))
          : ListView.builder(
              itemCount: myList.length,
              itemBuilder: (_, i) {
                final c = myList[i];
                return Card(
                  child: ListTile(
                    title: Text(c.category),
                    subtitle: Text("Status: ${stages[c.level]}"),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ComplaintDetail(complaint: c),
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
/// DETAIL PAGE
/// ===============================
class ComplaintDetail extends StatelessWidget {
  final Complaint complaint;
  const ComplaintDetail({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complaint Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Category: ${complaint.category}"),
            const SizedBox(height: 8),
            Text("Room: ${complaint.room}"),
            const SizedBox(height: 8),
            const Text("Message",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Text(complaint.message),
            const Divider(height: 32),
            const Text("Status Tracker",
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Column(
              children: List.generate(
                stages.length,
                (i) => ListTile(
                  leading: Icon(
                    i < complaint.level
                        ? Icons.check_circle
                        : i == complaint.level
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                    color:
                        i <= complaint.level ? Colors.green : Colors.grey,
                  ),
                  title: Text(stages[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
