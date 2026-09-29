import 'package:cloud_firestore/cloud_firestore.dart';

import 'student_dashboard_view_model.dart';

class StudentDashboardRepository {
  final FirebaseFirestore _db;

  StudentDashboardRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  Stream<StudentDashboardViewModel> watchStudentDashboard(String admissionNo) {
    return _db.collection('users').doc(admissionNo).snapshots().map((
      docSnapshot,
    ) {
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return StudentDashboardViewModel.admissionOnly(
          admissionNo: admissionNo,
        );
      }

      final data = docSnapshot.data() as Map<String, dynamic>;
      return StudentDashboardViewModel.fromMap(
        admissionNo: admissionNo,
        data: data,
      );
    });
  }
}
