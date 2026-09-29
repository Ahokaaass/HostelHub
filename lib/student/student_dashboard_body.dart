import 'package:flutter/material.dart';

import '../core/emergency_service_tile.dart';
import '../core/service_tile.dart';
import '../dashboards/hostel_sec/hostel_sec_dashboard.dart';
import '../dashboards/mess/mess_sec/mess_sec_screen.dart';
import '../dashboards/wingsec/wingsec_attendance.dart';
import 'attendance/student_attendance_page.dart';
import 'complaint/complaint_home.dart';
import 'gate/gate_request_home.dart';
import 'mess/student_mess_page.dart';
import 'outgoing/outgoing_home.dart';
import 'payment/student_payment_page.dart';
import '../dashboards/emergency/student_emergency_page.dart';
import 'student_dashboard_view_model.dart';

const _kBlue = Color(0xFF1565C0);
const _kBlueTint = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);

class StudentDashboardBody extends StatelessWidget {
  final StudentDashboardViewModel vm;

  const StudentDashboardBody({super.key, required this.vm});

  static Widget sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: Color(0xFF1A1A2E),
      letterSpacing: -0.2,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (vm.isWingSec || vm.isHostelSec || vm.isMessSec) ...[
          sectionLabel('My Roles'),
          const SizedBox(height: 10),
          if (vm.isWingSec)
            _RoleSwitchCard(
              icon: Icons.groups_2_rounded,
              label: 'Wing Secretary',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WingSecAttendancePage(),
                ),
              ),
            ),
          if (vm.isWingSec && vm.isHostelSec) const SizedBox(height: 10),
          if (vm.isHostelSec)
            _RoleSwitchCard(
              icon: Icons.admin_panel_settings_rounded,
              label: 'Hostel Secretary',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const HostelSecretaryDashboard(),
                ),
              ),
            ),
          if ((vm.isWingSec || vm.isHostelSec) && vm.isMessSec)
            const SizedBox(height: 10),
          if (vm.isMessSec)
            _RoleSwitchCard(
              icon: Icons.restaurant_menu_rounded,
              label: 'Mess Secretary',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MessSecScreen()),
              ),
            ),
          const SizedBox(height: 28),
        ],

        sectionLabel('Services'),
        const SizedBox(height: 14),

        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.05,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ServiceTile(
              icon: Icons.arrow_outward_rounded,
              title: 'Outgoing',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OutgoingHome()),
              ),
            ),
            ServiceTile(
              icon: Icons.report_problem_rounded,
              title: 'Complaint',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ComplaintHome()),
              ),
            ),
            ServiceTile(
              icon: Icons.directions_walk_rounded,
              title: 'Gate Request',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GateRequestHome()),
              ),
            ),
            ServiceTile(
              icon: Icons.calendar_month_rounded,
              title: 'My Attendance',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const StudentAttendancePage(),
                ),
              ),
            ),
            ServiceTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'My Payments',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentPaymentPage()),
              ),
            ),
            ServiceTile(
              icon: Icons.restaurant_menu_rounded,
              title: 'Mess',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentMessPage()),
              ),
            ),
            EmergencyServiceTile(
              userId: vm.admissionNo,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StudentEmergencyPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleSwitchCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _RoleSwitchCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _kBlueBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F1565C0),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _kBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Switch to',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: _kBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
