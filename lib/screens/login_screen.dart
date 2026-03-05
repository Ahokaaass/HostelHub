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

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController idController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  bool _hidePassword = true;
  bool _loading = false;
  String? _selectedHostel;

  static const List<String> _hostels = ['Kabini', 'Nila'];

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim =
        CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    idController.dispose();
    passController.dispose();
    _animController.dispose();
    super.dispose();
  }

  // ✅ LOGIN SUCCESS MESSAGE
  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Login successful"),
        backgroundColor: Color(0xFF1565C0),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // ================= LOGIN LOGIC =================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedHostel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select your hostel to continue"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

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
        Session.hostel = _selectedHostel!;

        _showSuccess();

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

        final studentUserId = parentData['studentUserId'].toString();

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
        Session.hostel = _selectedHostel!;

        _showSuccess();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ParentDashboard()),
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
        Session.hostel = _selectedHostel!;

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

        _showSuccess();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
        return;
      }

      throw "User not found";
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  // ─── REUSABLE INPUT DECORATION ─────────────────────────────────────────────
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF1565C0), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF1565C0), size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFFF0F5FF),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFBBD0F8), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF1565C0), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.8),
      ),
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8FF),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP BLUE HEADER ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.apartment_rounded,
                          color: Color(0xFF1565C0),
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "HostelHub",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Welcome Back",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Sign in to manage your hostel",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // ── FORM CARD ────────────────────────────────────────────────────
            Expanded(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── USER ID ──────────────────────────────────────
                          const Text(
                            "User ID",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: idController,
                            decoration: _inputDecoration(
                              label: "Enter your user ID",
                              icon: Icons.badge_outlined,
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? "User ID required"
                                    : null,
                          ),
                          const SizedBox(height: 20),

                          // ── PASSWORD ─────────────────────────────────────
                          const Text(
                            "Password",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: passController,
                            obscureText: _hidePassword,
                            decoration: _inputDecoration(
                              label: "Enter your password",
                              icon: Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF1565C0),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _hidePassword = !_hidePassword),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? "Password required"
                                    : null,
                          ),
                          const SizedBox(height: 28),

                          // ── HOSTEL SELECTION DIVIDER ──────────────────────
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  "Select Your Hostel",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.grey.shade300,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── HOSTEL DROPDOWN ───────────────────────────────
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F5FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedHostel == null
                                    ? const Color(0xFFBBD0F8)
                                    : const Color(0xFF1565C0),
                                width: _selectedHostel == null ? 1.4 : 1.8,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedHostel,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Color(0xFF1565C0),
                                ),
                                hint: Row(
                                  children: const [
                                    Icon(
                                      Icons.home_work_outlined,
                                      color: Color(0xFF1565C0),
                                      size: 20,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Choose hostel",
                                      style: TextStyle(
                                        color: Color(0xFF1565C0),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                items: _hostels.map((hostel) {
                                  return DropdownMenuItem(
                                    value: hostel,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.home_work_rounded,
                                          color: Color(0xFF1565C0),
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          hostel,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() => _selectedHostel = value);
                                },
                              ),
                            ),
                          ),

                          if (_selectedHostel == null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, left: 4),
                              child: Text(
                                "Hostel selection required to login",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),

                          const SizedBox(height: 32),

                          // ── LOGIN BUTTON ──────────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedHostel == null
                                    ? const Color(0xFFBBCFEE)
                                    : const Color(0xFF1565C0),
                                foregroundColor: Colors.white,
                                elevation: _selectedHostel == null ? 0 : 2,
                                shadowColor: const Color(0x441565C0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      "Login",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}