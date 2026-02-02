import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../office_admin/office_dashboard.dart';
import '../dashboards/warden_dashboard.dart';
import '../dashboards/rt_dashboard.dart';
import '../dashboards/wingsec/wingsec_attendance.dart';
import '../dashboards/matron/matron_dashboard.dart';
import '../student/student_dashboard.dart';
import '../parent/parent_dashboard.dart';
import '../student/student_data.dart';
import '../core/session.dart';
import '../dashboards/security/security_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    idController.dispose();
    passController.dispose();
    super.dispose();
  }

  // ✅ LOGIN SUCCESS MESSAGE
  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login successful"),
        backgroundColor: Color.fromARGB(255, 0, 60, 33),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ================= LOGIN LOGIC =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final userId = idController.text.trim();
    final password = passController.text.trim();

    try {
      // ================= STUDENT LOGIN =================
      final studentDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (studentDoc.exists) {
        final data = studentDoc.data()!;
        if (data['password'] != password) {
          throw "Invalid password";
        }

        StudentData.loadFromFirestore(data);

        Session.userId = userId;
        Session.role = "student";

        _showSuccess(); // ✅ ADDED

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentDashboard()),
        );
        return;
      }

      // ================= PARENT LOGIN =================
      final parentDoc = await FirebaseFirestore.instance
          .collection('parents')
          .doc(userId)
          .get();

      if (parentDoc.exists) {
        final parentData = parentDoc.data()!;

        if (parentData['parentPassword'] != password) {
          throw "Invalid parent password";
        }

        final studentUserId =
            parentData['studentUserId'].toString();

        final studentDoc2 = await FirebaseFirestore.instance
            .collection('users')
            .doc(studentUserId)
            .get();

        if (!studentDoc2.exists) {
          throw "Linked student not found";
        }

        StudentData.loadFromFirestore(studentDoc2.data()!);

        Session.userId = userId;
        Session.role = "parent";

        _showSuccess(); // ✅ ADDED

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ParentDashboard(),
          ),
        );
        return;
      }

      // ================= STAFF LOGIN =================
      final staffDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(userId)
          .get();

      if (staffDoc.exists) {
        final data = staffDoc.data()!;
        if (data['password'] != password) {
          throw "Invalid password";
        }

        final role = data['role'];

        Session.userId = userId;
        Session.role = role;

        late Widget page;

        if (role == 'office' || role == 'admin') {
          page = const OfficeDashboard();
        } else if (role == 'warden') {
          page = const WardenDashboard();
        } else if (role == 'rt') {
          page = const RTDashboard();
        } else if (role == 'wingsec') {
          page = const WingSecAttendancePage();
        } else if (role == 'matron') {
          page = const MatronDashboard();
        } else if (role == 'security') {
          page = const SecurityDashboard();
        } else {
          throw "Unauthorized role";
        }

        _showSuccess(); // ✅ ADDED

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
        return;
      }

      throw "User not found";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF3A6B52),
                    child: Icon(
                      Icons.apartment,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "HostelHub",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3A6B52),
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: idController,
                    decoration: const InputDecoration(
                      labelText: "User ID",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "User ID required" : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: passController,
                    obscureText: _hidePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Password required" : null,
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3A6B52),
                        foregroundColor: Colors.white,
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : const Text(
                              "Login",
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
