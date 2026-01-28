import 'package:flutter/material.dart';
import '../core/dashboard_scaffold.dart';
import '../student/student_data.dart';
import 'parent_attendance_page.dart';
import 'parent_profile_page.dart';


class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: "Parent Dashboard",
      userName: "Parent of ${StudentData.name}",
      onProfileTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>  ParentProfilePage(),
      ),
    );
  },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= STUDENT INFO =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Student Information",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3A6B52),
                  ),
                ),
                const SizedBox(height: 8),
                Text("Name: ${StudentData.name}"),
                Text("Room: ${StudentData.room ?? 'N/A'}"),
                Text("Department: ${StudentData.department ?? 'N/A'}"),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// ================= SERVICES =================
          const Text(
            "Parent Services",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3A6B52),
            ),
          ),

          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            children: [
              _serviceTile(
                icon: Icons.person,
                title: "Student Details",
                onTap: () {
                  _showStudentDetails(context);
                },
              ),

              _serviceTile(
                icon: Icons.calendar_month,
                title: "Attendance",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ParentAttendancePage(),
                    ),
                  );
                },
              ),

              _serviceTile(
                icon: Icons.account_balance_wallet,
                title: "Fee Details",
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Fee details coming soon"),
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

  // ================= TILE =================
  Widget _serviceTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFEAF4EE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3A6B52)),
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

  // ================= STUDENT DETAILS =================
  void _showStudentDetails(BuildContext context) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Student Details"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailItem("Name", StudentData.name),
            _detailItem("Admission No", StudentData.admissionNo),
            _detailItem("Department", StudentData.department ?? "N/A"),
            _detailItem("Room", StudentData.room ?? "N/A"),
            _detailItem("Phone", StudentData.phone),
            _detailItem("Email", StudentData.email),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Close"),
        ),
      ],
    ),
  );
}
Widget _detailItem(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          softWrap: true,
        ),
      ],
    ),
  );
}

  Widget _row(String l, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: const TextStyle(color: Colors.grey)),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
