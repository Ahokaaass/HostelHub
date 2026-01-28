import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/session.dart';
import '../../services/notification_service.dart';
import 'emergency_model.dart';

class EmergencyDetailPage extends StatelessWidget {
  final EmergencyModel emergency;

  const EmergencyDetailPage({
    super.key,
    required this.emergency,
  });

  String get role => Session.role ?? "unknown";

  // ================= MARK AS RECEIVED =================
  Future<void> _markReceived(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergency.id)
        .update({
      "status": "received",
      "receivedBy": role,
    });

    await NotificationService.send(
      message: "Emergency received by $role",
      type: "emergency",
    );

    Navigator.pop(context);
  }

  // ================= MARK AS HANDLED =================
  Future<void> _markHandled(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergency.id)
        .update({
      "status": "handled",
      "handledBy": role,
    });

    await NotificationService.send(
      message: "Emergency handled by $role",
      type: "emergency",
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitted = emergency.status == "submitted";
    final bool isReceived = emergency.status == "received";
    final bool isHandled = emergency.status == "handled";

    Color statusColor;
    if (isHandled) {
      statusColor = Colors.green;
    } else if (isReceived) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Details"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========= TITLE =========
            Text(
              emergency.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            Text("Severity: ${emergency.severity}"),

            const Divider(height: 30),

            // ========= MESSAGE =========
            Text(
              emergency.message,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 24),

            // ========= STATUS =========
            Text(
              "Status: ${emergency.status.toUpperCase()}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),

            if (emergency.receivedBy != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Received by: ${emergency.receivedBy}"),
              ),

            if (emergency.handledBy != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text("Handled by: ${emergency.handledBy}"),
              ),

            const Spacer(),

            // ========= ACTION BUTTONS =========

            // SUBMITTED → RECEIVED
            if (isSubmitted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _markReceived(context),
                  child: const Text("Mark as Received"),
                ),
              ),

            // RECEIVED → HANDLED
            if (isReceived)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () => _markHandled(context),
                  child: const Text("Mark as Handled"),
                ),
              ),

            // HANDLED
            if (isHandled)
              const Center(
                child: Text(
                  "Emergency Resolved",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
