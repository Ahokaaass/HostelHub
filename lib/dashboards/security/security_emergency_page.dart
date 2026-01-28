import 'package:flutter/material.dart';

class SecurityEmergencyPage extends StatelessWidget {
  const SecurityEmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Alerts"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _EmergencyTile(
            "Fire Drill",
            "Block B",
            Colors.red,
          ),
          _EmergencyTile(
            "Medical Assistance",
            "Hostel A",
            Colors.orange,
          ),
        ],
      ),
    );
  }
}

class _EmergencyTile extends StatelessWidget {
  final String title;
  final String location;
  final Color color;

  const _EmergencyTile(this.title, this.location, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.1),
      child: ListTile(
        leading: Icon(Icons.warning, color: color),
        title: Text(title),
        subtitle: Text("Location: $location"),
        trailing: Text(
          "ACTIVE",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
