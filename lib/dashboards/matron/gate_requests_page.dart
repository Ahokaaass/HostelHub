import 'package:flutter/material.dart';
import '../../services/notification_service.dart';

enum GateStatus { pending, approved, rejected, forwarded }

class GateRequest {
  final String name;
  final String room;
  final String reason;
  GateStatus status;

  GateRequest({
    required this.name,
    required this.room,
    required this.reason,
    this.status = GateStatus.pending,
  });
}

class GateRequestsPage extends StatefulWidget {
  const GateRequestsPage({super.key});

  @override
  State<GateRequestsPage> createState() => _GateRequestsPageState();
}

class _GateRequestsPageState extends State<GateRequestsPage> {
  final List<GateRequest> requests = [
    GateRequest(
      name: "Aswathy PJ",
      room: "1313",
      reason: "Home visit",
    ),
    GateRequest(
      name: "Sherin Ibadhi K",
      room: "1313",
      reason: "Medical checkup",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gate Requests"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: requests.length,
        itemBuilder: (_, i) {
          final r = requests[i];

          return Card(
            child: ListTile(
              title: Text("${r.name} (Room ${r.room})"),
              subtitle: Text(r.reason),
              trailing: _statusText(r.status),
              onTap: () => _openDetails(r),
            ),
          );
        },
      ),
    );
  }

  Widget _statusText(GateStatus s) {
    Color c;
    String t;

    switch (s) {
      case GateStatus.approved:
        c = Colors.green;
        t = "Approved";
        break;
      case GateStatus.rejected:
        c = Colors.red;
        t = "Rejected";
        break;
      case GateStatus.forwarded:
        c = Colors.blue;
        t = "Forwarded";
        break;
      default:
        c = Colors.orange;
        t = "Pending";
    }

    return Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold));
  }

  void _openDetails(GateRequest r) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GateRequestDetailPage(request: r),
      ),
    );
    setState(() {});
  }
}

/// ================= DETAILS PAGE =================

class GateRequestDetailPage extends StatelessWidget {
  final GateRequest request;
  const GateRequestDetailPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.name,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text("Room: ${request.room}"),
            const SizedBox(height: 16),
            Text("Reason:\n${request.reason}"),
            const Spacer(),

            if (request.status == GateStatus.pending)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green),
                      onPressed: () =>
                          _update(context, request, GateStatus.approved),
                      child: const Text("Approve"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red),
                      onPressed: () =>
                          _update(context, request, GateStatus.rejected),
                      child: const Text("Reject"),
                    ),
                  ),
                ],
              )
            else if (request.status == GateStatus.approved)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _update(context, request, GateStatus.forwarded),
                  child: const Text("Forward to Higher Authority"),
                ),
              )
            else
              Center(
                child: Text(
                  request.status == GateStatus.rejected
                      ? "Rejected"
                      : "Forwarded",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _update(BuildContext c, GateRequest r, GateStatus s) async {
  r.status = s;

  await NotificationService.send(
    message: "Gate request of ${r.name} was ${s.name.toUpperCase()}",
    type: "normal",
  );

  Navigator.pop(c);
}

}
