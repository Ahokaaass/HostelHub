import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';
import '../core/emergency_service_tile.dart';
import '../staff/profile/staff_profile_page.dart';
import 'student_list_page.dart';
import 'request_complaint_page.dart';
import '../dashboards/emergency/emergency_page.dart';
import '../dashboards/matron/send_notification_page.dart';
import 'rt_mess_page.dart'; // ← ADD

class RTDashboard extends StatefulWidget {
  const RTDashboard({super.key});

  @override
  State<RTDashboard> createState() => _RTDashboardState();
}

class _RTDashboardState extends State<RTDashboard> {
  static const _userId = 'rt@nila';

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
          .collection('staff')
          .doc(_userId)
          .get();
      setState(
          () => _userName = doc.data()?['name'] ?? 'RT Staff');
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
      userName     : _loading ? '...' : _userName,
      onProfileTap : () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  const StaffProfilePage(userId: _userId))),
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
            crossAxisCount  : 2,
            shrinkWrap      : true,
            physics         :
                const NeverScrollableScrollPhysics(),
            mainAxisSpacing : 16,
            crossAxisSpacing: 16,
            children: [
              ServiceTile(
                icon : Icons.people,
                title: 'Student Records',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const StudentListPage())),
              ),
              ServiceTile(
                icon : Icons.assignment,
                title: 'Requests & Complaints',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const RequestComplaintPage())),
              ),
              ServiceTile(
                icon : Icons.notifications,
                title: 'Send Notification',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const SendNotificationPage())),
              ),
              // ── ADD: Mess tile ─────────────────────────────
              ServiceTile(
                icon : Icons.restaurant_menu_rounded,
                title: 'Mess',
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const RtMessPage())),
              ),
              EmergencyServiceTile(
                userId: _userId,
                onTap : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            const EmergencyPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}