import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OutgoingListPage extends StatelessWidget {
  final String type;
  const OutgoingListPage({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(type),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('outgoing')
            .where('type', isEqualTo: type)
            .snapshots(),
        builder: (_, s) {
          if (!s.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (s.data!.docs.isEmpty) {
            return const Center(child: Text("No records"));
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: s.data!.docs.map((d) {
              final r = d.data() as Map<String, dynamic>;
              return Card(
                child: ListTile(
                  title: Text("${r['name']} (Room ${r['room']})"),
                  subtitle: Text(
                    "${r['place']}\n"
                    "Out: ${r['outDate']} • ${r['outTime']}\n"
                    "${r['returnDate'] == null
                        ? "Return: Not updated"
                        : "Return: ${r['returnDate']} • ${r['returnTime']}"}",
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
