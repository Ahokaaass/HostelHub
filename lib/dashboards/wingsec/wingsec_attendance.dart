import 'package:flutter/material.dart';

import '../../core/dashboard_scaffold.dart';
import 'take_attendance_page.dart';
import 'view_attendance_page.dart';

class WingSecAttendancePage extends StatelessWidget {
  const WingSecAttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Wing Secretary",
      userName: "Wing Secretary",

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔁 SWITCH BACK
          Card(
            color: Colors.orange.shade50,
            child: ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text(
                "Switch back to Student",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.pop(context),
            ),
          ),

          const SizedBox(height: 20),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _tile(
                context,
                "Take Attendance",
                Icons.edit,
                const TakeAttendancePage(),
              ),
              _tile(
                context,
                "View Attendance",
                Icons.visibility,
                const ViewAttendancePage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    String title,
    IconData icon,
    Widget page,
  ) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3A6B52)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
