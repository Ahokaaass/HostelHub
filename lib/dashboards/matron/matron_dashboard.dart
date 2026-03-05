import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/dashboard_scaffold.dart';
import '../../core/service_tile.dart';
import '../../core/emergency_service_tile.dart';
import '../../staff/profile/staff_profile_page.dart';
import 'attendance_view_page.dart';
import 'outgoing_category_page.dart';
import 'send_notification_page.dart';
import '../emergency/emergency_page.dart';
import '../../dashboards/request_complaint_page.dart';

class MatronDashboard extends StatefulWidget {
  const MatronDashboard({super.key});

  @override
  State<MatronDashboard> createState() => _MatronDashboardState();
}

class _MatronDashboardState extends State<MatronDashboard> {
  static const _userId = 'matron@nila';

  String _userName = '';
  bool   _loading  = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('staff').doc(_userId).get();
      setState(() => _userName = doc.data()?['name'] ?? 'Matron');
    } catch (_) {
      setState(() => _userName = 'Matron');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'Matron Dashboard',
      userName     : _loading ? '...' : _userName,
      onProfileTap : () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => const StaffProfilePage(userId: _userId))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services',
              style: TextStyle(
                  fontSize  : 18,
                  fontWeight: FontWeight.bold,
                  color     : Color(0xFF1565C0))),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap      : true,
            physics         : const NeverScrollableScrollPhysics(),
            crossAxisCount  : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing : 16,
            children: [
              ServiceTile(
                icon : Icons.fact_check_rounded,
                title: 'Attendance',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const AttendanceViewPage())),
              ),
              ServiceTile(
                icon : Icons.directions_walk_rounded,
                title: 'Outgoing Records',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const OutgoingCategoryPage())),
              ),
              ServiceTile(
                icon : Icons.assignment_rounded,
                title: 'Requests & Complaints',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const RequestComplaintPage())),
              ),
              ServiceTile(
                icon : Icons.notifications_rounded,
                title: 'Send Notification',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SendNotificationPage())),
              ),
              // ── Turns red when unread ──────────────────────────────────
              EmergencyServiceTile(
                userId: _userId,
                onTap : () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const EmergencyPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}