import 'package:flutter/material.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';

import '../staff/profile/staff_profile_page.dart';
import 'student_list_page.dart';
import 'request_complaint_page.dart';
import 'assign_role_page.dart';

import '../dashboards/emergency/emergency_page.dart'; // ✅ ADD
import '../dashboards/matron/send_notification_page.dart'; // ✅ REUSE

class WardenDashboard extends StatelessWidget {
  const WardenDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Warden Dashboard",
      userName: "Fahmi Sara", // dummy (can later load from Firestore)

      // ✅ PROFILE ICON
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StaffProfilePage(userId: "warden"),
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
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              // ================= EXISTING =================

              ServiceTile(
                icon: Icons.people,
                title: "Student Records",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentListPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.assignment,
                title: "Requests & Complaints",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RequestComplaintPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.admin_panel_settings,
                title: "Assign Roles",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AssignRolePage(),
                    ),
                  );
                },
              ),

              // ================= NEW =================

              ServiceTile(
                icon: Icons.warning,
                title: "Emergency Alerts",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EmergencyPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.notifications,
                title: "Send Notification",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SendNotificationPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
