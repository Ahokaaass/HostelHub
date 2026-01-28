import 'package:flutter/material.dart';
import 'outgoing_list_page.dart';

class OutgoingCategoryPage extends StatelessWidget {
  const OutgoingCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Outgoing Records"),
        backgroundColor: const Color(0xFF3A6B52),
      ),
      body: Column(
        children: [
          _tile(context, "Outgoing"),
          _tile(context, "Home Going"),
          _tile(context, "Hospital Going"),
        ],
      ),
    );
  }

  Widget _tile(BuildContext c, String type) {
    return Card(
      child: ListTile(
        title: Text(type),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            c,
            MaterialPageRoute(
              builder: (_) => OutgoingListPage(type: type),
            ),
          );
        },
      ),
    );
  }
}
