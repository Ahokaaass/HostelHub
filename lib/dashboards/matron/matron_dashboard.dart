import 'package:flutter/material.dart';

import '../../core/dashboard_scaffold.dart';
import '../../staff/profile/staff_profile_page.dart';

import 'attendance_view_page.dart';
import 'outgoing_category_page.dart';
import 'gate_requests_page.dart';
import 'send_notification_page.dart';
import '../emergency/emergency_page.dart'; // ✅ IMPORTANT

class MatronDashboard extends StatelessWidget {
  const MatronDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Matron Dashboard",
      userName: "Hostel Matron",

      // ✅ PROFILE ICON WORKING
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const StaffProfilePage(userId: "matron@nila"),
          ),
        );
      },

      body: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _tile(
            context,
            Icons.fact_check,
            "Attendance",
            const AttendanceViewPage(),
          ),
          _tile(
            context,
            Icons.directions_walk,
            "Outgoing Records",
            const OutgoingCategoryPage(),
          ),
          _tile(
            context,
            Icons.exit_to_app,
            "Gate Requests",
            const GateRequestsPage(),
          ),
          _tile(
            context,
            Icons.warning,
            "Emergency Alerts",
            const EmergencyPage(), // ✅ BACKEND DATA
          ),
          _tile(
            context,
            Icons.notifications,
            "Send Notification",
            const SendNotificationPage(),
          ),
        ],
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
