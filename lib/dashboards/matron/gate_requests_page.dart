// ============================================================
// FILE: lib/dashboards/matron/gate_requests_page.dart
// ============================================================

import 'package:flutter/material.dart';
import '../../model/gate_request_model.dart';

class GateRequestsPage extends StatelessWidget {
  const GateRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gate Requests"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<List<GateRequest>>(
        stream: GateRequestService.streamForMatron(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 56, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    "No pending requests",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF3A6B52),
                    child: Text(
                      r.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text("${r.name} (Room ${r.room})"),
                  subtitle: Text(
                    r.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GateRequestDetailPage(requestId: r.id),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class GateRequestDetailPage extends StatelessWidget {
  final String requestId;
  const GateRequestDetailPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Request Details"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<GateRequest?>(
        stream: GateRequestService.streamSingle(requestId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError || snap.data == null) {
            return Center(child: Text("Error: ${snap.error ?? 'Not found'}"));
          }
          return _DetailBody(request: snap.data!);
        },
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  final GateRequest request;
  const _DetailBody({required this.request});

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text("Room: ${r.room}"),
          Text("Phone: ${r.phone}"),
          Text("Type: ${r.type}"),
          Text("Date: ${r.date}   Time: ${r.time}"),
          const SizedBox(height: 12),
          const Text(
            "Reason",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          Text(r.reason),
          const Spacer(),

          if (r.status == GateStatus.pending)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () => _showDeclineDialog(context, r),
                    child: const Text(
                      "Decline",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () => _forward(context, r),
                    child: const Text(
                      "Forward to RT",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            )
          else
            Center(
              child: Column(
                children: [
                  Icon(
                    r.status == GateStatus.matronDecline
                        ? Icons.cancel
                        : Icons.check_circle,
                    color: r.status == GateStatus.matronDecline
                        ? Colors.red
                        : Colors.green,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    r.status == GateStatus.matronDecline
                        ? "Declined"
                        : "Forwarded to RT",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (r.matronDeclineReason != null)
                    Text(
                      "Reason: ${r.matronDeclineReason}",
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _forward(BuildContext context, GateRequest r) async {
    try {
      await GateRequestService.updateStatus(r.id, {
        'status': GateStatus.matronForward,
      });
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  void _showDeclineDialog(BuildContext context, GateRequest r) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Reason for Declining"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Please enter a reason:"),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Enter reason...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await GateRequestService.updateStatus(r.id, {
                'status': GateStatus.matronDecline,
                'matronDeclineReason': ctrl.text.trim(),
              });
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text("Decline", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}