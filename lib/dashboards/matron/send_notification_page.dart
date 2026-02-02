import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';
import '../../core/session.dart';

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() =>
      _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController msgCtrl = TextEditingController();
  String type = "normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Notice"),
        backgroundColor: const Color(0xFF3A6B52),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: type,
              items: const [
                DropdownMenuItem(value: "normal", child: Text("Normal")),
                DropdownMenuItem(value: "emergency", child: Text("Emergency")),
              ],
              onChanged: (v) => setState(() => type = v!),
              decoration: const InputDecoration(
                labelText: "Notification Type",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: msgCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Message",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (msgCtrl.text.trim().isEmpty) return;

                  // 🔥 Emergency record
                  if (type == "emergency") {
                    await FirebaseFirestore.instance
                        .collection('emergencies')
                        .add({
                      "title": "Emergency Alert",
                      "message": msgCtrl.text.trim(),
                      "severity": "High",
                      "createdBy": Session.role,
                      "createdAt": Timestamp.now(),
                      "status": "submitted",
                      "receivedBy": null,
                      "handledBy": null,
                    });
                  }

                  // 🔔 Notification (UNREAD)
                  await NotificationService.send(
                    message: msgCtrl.text.trim(),
                    type: type,
                    extraData: {
                      "createdBy": Session.role,
                    },
                  );

                  Navigator.pop(context);
                },
                child: const Text("Send"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
