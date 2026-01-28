import 'package:flutter/material.dart';

import '../core/dashboard_scaffold.dart';
import '../staff/profile/staff_profile_page.dart';

import 'student_list_page.dart';
import 'request_complaint_page.dart';

import '../dashboards/emergency/emergency_page.dart'; // ✅ ADD
import '../dashboards/matron/send_notification_page.dart'; // ✅ REUSE

class RTDashboard extends StatelessWidget {
  const RTDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "RT Dashboard",
      userName: "Fahmi Sara",

      // ✅ PROFILE ICON
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const StaffProfilePage(userId: "rt@nila"),
          ),
        );
      },

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Services",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A6B52),
            ),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            children: [
              // ================= SAME AS WARDEN =================

              _serviceTile(
                context,
                icon: Icons.people,
                title: "Student Records",
                page: const StudentListPage(),
              ),

              _serviceTile(
                context,
                icon: Icons.report_problem,
                title: "Requests & Complaints",
                page: const RequestComplaintPage(),
              ),

              // ================= NEW =================

              _serviceTile(
                context,
                icon: Icons.warning,
                title: "Emergency Alerts",
                page: const EmergencyPage(),
              ),

              _serviceTile(
                context,
                icon: Icons.notifications,
                title: "Send Notification",
                page: const SendNotificationPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= TILE =================
  Widget _serviceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget page,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: const Color(0xFF3A6B52)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF3A6B52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
