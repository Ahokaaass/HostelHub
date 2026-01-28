import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';
import 'student_data.dart';
import 'outgoing/outgoing_home.dart';
import 'complaint/complaint_home.dart';
import 'gate/gate_request_home.dart';
import 'profile/profile_page.dart';

import '../dashboards/wingsec/wingsec_attendance.dart';
import '../dashboards/hostel_sec/hostel_sec_dashboard.dart';
import 'attendance/student_attendance_page.dart'; // ✅ ADD

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(StudentData.admissionNo)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final bool isWingSec = data['isWingSecretary'] == true;
        final bool isHostelSec = data['isHostelSecretary'] == true;

        return DashboardScaffold(
          dashboardName: "Student Dashboard",
          userName: StudentData.name,

          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfilePage(admissionNo: StudentData.admissionNo),
              ),
            );
          },

          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔁 SWITCH TO WING SECRETARY
              if (isWingSec)
                Card(
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text(
                      "Switch to Wing Secretary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WingSecAttendancePage(),
                        ),
                      );
                    },
                  ),
                ),

              if (isWingSec) const SizedBox(height: 20),

              // 🔁 SWITCH TO HOSTEL SECRETARY
              if (isHostelSec)
                Card(
                  color: Colors.orange.shade50,
                  child: ListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: const Text(
                      "Switch to Hostel Secretary",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const HostelSecretaryDashboard(),
                        ),
                      );
                    },
                  ),
                ),

              if (isHostelSec) const SizedBox(height: 20),

              // ================= SERVICES =================
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ServiceTile(
                    icon: Icons.arrow_outward,
                    title: "Outgoing",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OutgoingHome(),
                        ),
                      );
                    },
                  ),

                  ServiceTile(
                    icon: Icons.warning_amber,
                    title: "Complaint",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ComplaintHome(),
                        ),
                      );
                    },
                  ),

                  ServiceTile(
                    icon: Icons.directions_walk,
                    title: "Gate\nRequest",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const GateRequestHome(),
                        ),
                      );
                    },
                  ),

                  // ✅ NEW: MY ATTENDANCE
                  ServiceTile(
                    icon: Icons.calendar_month,
                    title: "My\nAttendance",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const StudentAttendancePage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
