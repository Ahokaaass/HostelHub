import 'package:flutter/material.dart';
import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';

import '../staff/profile/staff_profile_page.dart'; // ✅ ADD
import 'student_records.dart';
import 'complaints.dart';
import 'staff_page.dart';

class OfficeDashboard extends StatelessWidget {
  const OfficeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Office Admin Dashboard",
      userName: "Hostel Administration",
      

      // ✅ THIS FIXES PROFILE ICON
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const StaffProfilePage(userId: "admin@geci"),
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
            crossAxisCount:
                MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              ServiceTile(
                icon: Icons.people,
                title: "Student Records",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StudentRecordsPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.chat_bubble_outline,
                title: "Complaints",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ComplaintsPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.admin_panel_settings,
                title: "Staff Management",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaffPage(),
                    ),
                  );
                },
              ),

              ServiceTile(
                icon: Icons.account_balance_wallet,
                title: "Budget",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Budget module coming soon"),
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
