import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';

import '../staff/profile/staff_profile_page.dart';
import 'student_records.dart';
import 'complaints.dart';
import 'staff_page.dart';
import 'budget_page.dart';

class OfficeDashboard extends StatefulWidget {
  const OfficeDashboard({super.key});

  @override
  State<OfficeDashboard> createState() => _OfficeDashboardState();
}

class _OfficeDashboardState extends State<OfficeDashboard> {
  static const _userId = 'admin@geci';

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
      setState(() => _userName = doc.data()?['name'] ?? 'Admin');
    } catch (_) {
      setState(() => _userName = 'Admin');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Office Admin Dashboard",
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
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StudentRecordsPage())),
              ),

              ServiceTile(
                icon: Icons.chat_bubble_outline,
                title: "Complaints",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ComplaintsPage())),
              ),

              ServiceTile(
                icon: Icons.admin_panel_settings,
                title: "Staff Management",
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StaffPage())),
              ),

              ServiceTile(
                icon: Icons.account_balance_wallet,
                title: "Budget",
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}