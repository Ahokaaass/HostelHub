import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/dashboard_scaffold.dart';
import '../core/service_tile.dart';
import '../core/emergency_service_tile.dart';
import '../student/student_data.dart';
import 'parent_attendance_page.dart';
import 'parent_profile_page.dart';
import '../dashboards/emergency/student_emergency_page.dart';

const _kBlue       = Color(0xFF1565C0);
const _kBlueTint   = Color(0xFFE8F0FE);
const _kBlueBorder = Color(0xFFBBD0F8);
const _kDark       = Color(0xFF1A1A2E);

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  // Unique ID so parent's read-status is tracked separately from student
  static String get _userId => 'parent_${StudentData.admissionNo}';

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'Parent Dashboard',
      userName     : 'Parent of ${StudentData.name}',
      onProfileTap : () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ParentProfilePage()),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Services',
            style: TextStyle(
              fontSize     : 16,
              fontWeight   : FontWeight.w800,
              color        : _kDark,
              letterSpacing: -0.2,
            ),
          ),
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
                icon : Icons.person_rounded,
                title: 'Student Details',
                onTap: () => showModalBottomSheet(
                  context           : context,
                  isScrollControlled: true,
                  backgroundColor   : Colors.transparent,
                  builder           : (_) => const _StudentDetailsSheet(),
                ),
              ),
              ServiceTile(
                icon : Icons.calendar_month_rounded,
                title: 'Attendance',
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const ParentAttendancePage())),
              ),
              ServiceTile(
                icon : Icons.account_balance_wallet_rounded,
                title: 'Fee Details',
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content : const Text('Fee details coming soon'),
                    behavior: SnackBarBehavior.floating,
                    shape   : RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              // ── Turns red when unread, normal when opened ──────────────
              EmergencyServiceTile(
                userId: _userId,
                onTap : () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const StudentEmergencyPage())),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Student Details Bottom Sheet ──────────────────────────────────────────────
class _StudentDetailsSheet extends StatelessWidget {
  const _StudentDetailsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color        : Color(0xFFF5F8FF),
        borderRadius : BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children    : [
          Container(
            margin     : const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration : BoxDecoration(
              color       : const Color(0xFFD1D5DB),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            margin : const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient    : const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1E88E5)],
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(children: [
              Container(
                width : 52, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initials(StudentData.name),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(StudentData.name,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(
                      '${StudentData.department ?? ''} · ${StudentData.semester ?? ''}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Container(
              decoration: BoxDecoration(
                color      : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border     : Border.all(color: _kBlueBorder.withOpacity(0.5), width: 1),
                boxShadow  : const [BoxShadow(color: Color(0x0A1565C0), blurRadius: 10, offset: Offset(0, 3))],
              ),
              child: Column(children: [
                _row(Icons.confirmation_number_rounded, 'Admission No', StudentData.admissionNo),
                _div(),
                _row(Icons.school_rounded,       'Department', StudentData.department ?? 'N/A'),
                _div(),
                _row(Icons.class_rounded,         'Semester',   StudentData.semester   ?? 'N/A'),
                _div(),
                _row(Icons.meeting_room_rounded,  'Room',       '${StudentData.room    ?? 'N/A'}'),
                _div(),
                _row(Icons.phone_rounded,         'Phone',      StudentData.phone),
                _div(),
                _row(Icons.email_rounded,         'Email',      StudentData.email),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _row(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child  : Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: _kBlueTint, borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, color: _kBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontWeight: FontWeight.w500))),
          Flexible(child: Text(value,
              textAlign: TextAlign.end,
              overflow : TextOverflow.ellipsis,
              style    : const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)))),
        ]),
      );

  static Widget _div() => const Divider(height: 1, indent: 60, color: Color(0xFFF0F4FF));

  static String _initials(String name) {
    final p = name.trim().split(RegExp(r'\s+'));
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}