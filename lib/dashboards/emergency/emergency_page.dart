import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'emergency_detail_page.dart';
import 'emergency_model.dart';

class EmergencyPage extends StatelessWidget {
  const EmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Alerts"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('emergencies')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No emergency alerts"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];

              // ✅ CORRECT WAY (NO ERRORS)
              final emergency = EmergencyModel.fromDoc(doc);

              return _emergencyTile(context, emergency);
            },
          );
        },
      ),
    );
  }

  // ================= TILE =================
  Widget _emergencyTile(
    BuildContext context,
    EmergencyModel e,
  ) {
    Color bgColor;
    Color iconColor;
    String statusText;

    if (e.status == "handled") {
      bgColor = Colors.green.shade50;
      iconColor = Colors.green;
      statusText = "RESOLVED";
    } else if (e.status == "received") {
      bgColor = Colors.orange.shade50;
      iconColor = Colors.orange;
      statusText = "RECEIVED";
    } else {
      bgColor = Colors.red.shade50;
      iconColor = Colors.red;
      statusText = "ACTIVE";
    }

    return Card(
      color: bgColor,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(Icons.warning, color: iconColor),
        title: Text(
          e.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${e.message}\nSeverity: ${e.severity}",
        ),
        trailing: Text(
          statusText,
          style: TextStyle(
            color: iconColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmergencyDetailPage(emergency: e),
            ),
          );
        },
      ),
    );
  }
}
