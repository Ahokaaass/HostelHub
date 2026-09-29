import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';
import '../core/emergency_service_tile.dart';
import '../staff/profile/staff_profile_page.dart';
import 'student_list_page.dart';
import 'request_list_page.dart';
import 'rt_complaint_list_page.dart';
import '../dashboards/emergency/emergency_page.dart';
import '../dashboards/matron/send_notification_page.dart';
import 'rt_mess_page.dart';

class RTDashboard extends StatefulWidget {
  const RTDashboard({super.key});

  @override
  State<RTDashboard> createState() => _RTDashboardState();
}

class _RTDashboardState extends State<RTDashboard> {
  static const _userId = 'rt@nila';

  String _userName = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(_userId)
          .get();
      setState(() => _userName = doc.data()?['name'] ?? 'RT Staff');
    } catch (_) {
      setState(() => _userName = 'RT Staff');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'RT Dashboard',
      userName: _loading ? '...' : _userName,
      onProfileTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StaffProfilePage(userId: _userId),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            children: [
              ServiceTile(
                icon: Icons.people,
                title: 'Student Records',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentListPage()),
                ),
              ),
              ServiceTile(
                icon: Icons.assignment,
                title: 'Requests & Complaints',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const _RequestsComplaintsMenu(),
                  ),
                ),
              ),
              ServiceTile(
                icon: Icons.notifications,
                title: 'Send Notification',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SendNotificationPage(),
                  ),
                ),
              ),
              ServiceTile(
                icon: Icons.restaurant_menu_rounded,
                title: 'Mess',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RtMessPage()),
                ),
              ),
              EmergencyServiceTile(
                userId: _userId,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Requests & Complaints Menu ────────────────────────────────────────────────
class _RequestsComplaintsMenu extends StatelessWidget {
  const _RequestsComplaintsMenu();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FB),
      body: Column(
        children: [
          // ── Gradient header with rounded bottom ──────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 16, 28),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 4),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Requests & Complaints',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Manage student submissions',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "Select Category" label row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.grid_view_rounded,
                          size: 16,
                          color: Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Category',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _MenuCard(
                    icon: Icons.assignment_turned_in_rounded,
                    title: 'View Requests',
                    subtitle: 'Review and manage student requests',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const RequestListPage(role: ViewerRole.rt),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _MenuCard(
                    icon: Icons.warning_amber_rounded,
                    title: 'View Complaints',
                    subtitle: 'Forward or reject student complaints',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RtComplaintListPage(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE3EAF5)),
          ),
          child: Row(
            children: [
              // Icon box
              Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
              ),
              const SizedBox(width: 16),

              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF8499B0),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Arrow button
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFEBF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 15,
                  color: Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
