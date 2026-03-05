import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/dashboard_scaffold.dart';
import '../../core/service_tile.dart';
import '../../core/emergency_service_tile.dart';
import '../../staff/profile/staff_profile_page.dart';
import 'security_log_page.dart';
import 'security_emergency_page.dart';

const _kBlue = Color(0xFF1565C0);
const _kDark = Color(0xFF1A1A2E);

class SecurityDashboard extends StatefulWidget {
  const SecurityDashboard({super.key});

  @override
  State<SecurityDashboard> createState() => _SecurityDashboardState();
}

class _SecurityDashboardState extends State<SecurityDashboard> {
  static const _userId = 'security';

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
      setState(() => _userName = doc.data()?['name'] ?? 'Security Staff');
    } catch (_) {
      setState(() => _userName = 'Security Staff');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'Security Dashboard',
      userName     : _loading ? '...' : _userName,
      onProfileTap : () => Navigator.push(context,
          MaterialPageRoute(
              builder: (_) => const StaffProfilePage(userId: _userId))),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Services',
              style: TextStyle(
                  fontSize     : 16,
                  fontWeight   : FontWeight.w800,
                  color        : _kDark,
                  letterSpacing: -0.2)),
          const SizedBox(height: 14),

          GridView.count(
            crossAxisCount  : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing : 16,
            childAspectRatio: 1.05,
            shrinkWrap      : true,
            physics         : const NeverScrollableScrollPhysics(),
            children: [
              ServiceTile(
                icon : Icons.receipt_long_rounded,
                title: "Today's Log",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const SecurityLogPage())),
              ),
              // ── Turns red when unread ──────────────────────────────────
              EmergencyServiceTile(
                userId: _userId,
                onTap : () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const SecurityEmergencyPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}