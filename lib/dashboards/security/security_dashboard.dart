import 'package:flutter/material.dart';

import '../../core/dashboard_scaffold.dart';
import '../../staff/profile/staff_profile_page.dart';
import 'security_log_page.dart';
import 'security_emergency_page.dart';

class SecurityDashboard extends StatelessWidget {
  const SecurityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Security Dashboard",
      userName: "Main Gate • Security Staff",

      // ✅ PROFILE ICON WORKS
      onProfileTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const StaffProfilePage(userId: "security"),
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
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _serviceTile(
                context,
                Icons.receipt_long,
                "Today's Log",
                const SecurityLogPage(),
              ),
              _serviceTile(
                context,
                Icons.warning_amber_rounded,
                "Emergency Alerts",
                const SecurityEmergencyPage(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceTile(
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
          color: const Color(0xFFEAF4F0),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: const Color(0xFF3A6B52)),
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
