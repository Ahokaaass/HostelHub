import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    NotificationService.markAllRead(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        backgroundColor: const Color(0xFF3A6B52),
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
              final d = docs[i].data() as Map<String, dynamic>;
              final isEmergency = d['type'] == 'emergency';

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  title: Text(d['message']),
                  subtitle: Text(
                    d['createdAt'] == null
                        ? ""
                        : DateFormat("d/M/yyyy • h:mm a")
                            .format(d['createdAt'].toDate()),
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
