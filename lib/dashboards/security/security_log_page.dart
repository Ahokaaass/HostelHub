import 'package:flutter/material.dart';

class SecurityLogPage extends StatelessWidget {
  const SecurityLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ================= DUMMY APPROVED LOGS =================
    final List<_SecurityLog> logs = [
      _SecurityLog(
        name: "Anjali R",
        room: "1312",
        time: "05:30 AM",
        type: LogType.earlyExit,
      ),
      _SecurityLog(
        name: "Fathima N",
        room: "1315",
        time: "05:50 AM",
        type: LogType.earlyEntry,
      ),
      _SecurityLog(
        name: "Sherin Ibadh K",
        room: "1313",
        time: "09:45 PM",
        type: LogType.lateEntry,
      ),
      _SecurityLog(
        name: "Ayesha M",
        room: "1320",
        time: "10:10 PM",
        type: LogType.lateExit,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Approved Security Log"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          return _logTile(log);
        },
      ),
    );
  }

  // ================= LOG TILE =================
  Widget _logTile(_SecurityLog log) {
    final bool isEarly =
        log.type == LogType.earlyEntry || log.type == LogType.earlyExit;

    final Color color = isEarly ? Colors.blue : Colors.red;
    final IconData icon = log.type == LogType.earlyEntry ||
            log.type == LogType.lateEntry
        ? Icons.login
        : Icons.logout;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: color.withOpacity(0.4)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          log.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Room: ${log.room}"),
            const SizedBox(height: 4),
            Text(
              "Time: ${log.time}",
              style: TextStyle(color: color),
            ),
          ],
        ),
        trailing: Text(
          log.label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ================= DATA MODEL =================

enum LogType {
  earlyEntry,
  earlyExit,
  lateEntry,
  lateExit,
}

class _SecurityLog {
  final String name;
  final String room;
  final String time;
  final LogType type;

  _SecurityLog({
    required this.name,
    required this.room,
    required this.time,
    required this.type,
  });

  String get label {
    switch (type) {
      case LogType.earlyEntry:
        return "EARLY ENTRY";
      case LogType.earlyExit:
        return "EARLY EXIT";
      case LogType.lateEntry:
        return "LATE ENTRY";
      case LogType.lateExit:
        return "LATE EXIT";
    }
  }
}
