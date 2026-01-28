class StudentData {
  static String name = "";
  static String email = "";
  static String admissionNo = "";
  static String phone = "";
  static String department = "";
  static String semester = "";
  static String room = ""; // ✅ ADD THIS

  static void loadFromFirestore(Map<String, dynamic> data) {
    name = data['name'] ?? "";
    email = data['email'] ?? "";
    admissionNo = data['admissionNo'] ?? "";
    phone = data['phone'] ?? "";
    department = data['department'] ?? "";
    semester = data['semester'] ?? "";
    room = data['room']?.toString() ?? ""; // ✅ SAFE CONVERSION
  }

  static void clear() {
    name = "";
    email = "";
    admissionNo = "";
    phone = "";
    department = "";
    semester = "";
    room = "";
  }
}
