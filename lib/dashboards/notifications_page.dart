import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatelessWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF3A6B52),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: NotificationService.allStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No notifications"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final bool isEmergency = data['type'] == 'emergency';
              final List readBy = data['readBy'] ?? [];
              final bool isUnread = !readBy.contains(userId);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: isEmergency ? Colors.red : Colors.green,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    isEmergency ? Icons.warning : Icons.notifications,
                    color: isEmergency ? Colors.red : Colors.green,
                  ),
                  title: Text(
                    data['message'] ?? "",
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat("d/M/yyyy • h:mm a")
                        .format(data['createdAt'].toDate()),
                  ),
                  onTap: isUnread
                      ? () async {
                          await NotificationService.markRead(
                            notificationId: doc.id,
                            userId: userId,
                          );
                        }
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
