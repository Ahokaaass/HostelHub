import 'package:flutter/material.dart';

import '../core/dashboard_scaffold.dart';
import 'student_data.dart';
import 'profile/profile_page.dart';
import 'student_dashboard_body.dart';
import 'student_dashboard_repository.dart';
import 'student_dashboard_view_model.dart';

const _kBlue = Color(0xFF1565C0);

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = StudentDashboardRepository();

    return StreamBuilder<StudentDashboardViewModel>(
      stream: repo.watchStudentDashboard(StudentData.admissionNo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F8FF),
            body: Center(child: CircularProgressIndicator(color: _kBlue)),
          );
        }

        final vm = snapshot.data;
        final safeVm = (vm == null || snapshot.hasError)
            ? StudentDashboardViewModel.admissionOnly(
                admissionNo: StudentData.admissionNo,
              )
            : vm;

        return DashboardScaffold(
          dashboardName: 'Student Dashboard',
          userName: safeVm.userName ?? '—',
          onProfileTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilePage(admissionNo: safeVm.admissionNo),
            ),
          ),
          body: StudentDashboardBody(vm: safeVm),
        );
      },
    );
  }
}
