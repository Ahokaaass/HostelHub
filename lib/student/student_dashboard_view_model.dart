class StudentDashboardViewModel {
  final String admissionNo;
  final String? userName;
  final bool isWingSec;
  final bool isHostelSec;
  final bool isMessSec;

  const StudentDashboardViewModel({
    required this.admissionNo,
    required this.userName,
    required this.isWingSec,
    required this.isHostelSec,
    required this.isMessSec,
  });

  factory StudentDashboardViewModel.admissionOnly({
    required String admissionNo,
  }) {
    return StudentDashboardViewModel(
      admissionNo: admissionNo,
      userName: null,
      isWingSec: false,
      isHostelSec: false,
      isMessSec: false,
    );
  }

  factory StudentDashboardViewModel.fromMap({
    required String admissionNo,
    required Map<String, dynamic> data,
  }) {
    final rawName = data['name'];
    final name = rawName?.toString().trim();
    return StudentDashboardViewModel(
      admissionNo: admissionNo,
      userName: (name == null || name.isEmpty) ? null : name,
      isWingSec: data['isWingSecretary'] == true,
      isHostelSec: data['isHostelSecretary'] == true,
      isMessSec: data['isMessSecretary'] == true,
    );
  }
}
