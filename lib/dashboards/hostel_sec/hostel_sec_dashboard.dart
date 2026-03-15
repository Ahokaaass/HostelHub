import 'package:flutter/material.dart';
import '../../core/dashboard_scaffold.dart';
import '../../core/service_tile.dart';
import '../matron/attendance_view_page.dart';
import 'hostel_sec_complaints_page.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class HostelSecretaryDashboard extends StatelessWidget {
  const HostelSecretaryDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScaffold(
      dashboardName: 'Hostel Secretary',
      userName     : 'Hostel Secretary',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Active Role Banner ────────────────────────────────────────
          Container(
            width  : double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color     : Color(0x301565C0),
                  blurRadius: 14,
                  offset    : Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width : 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color       : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35), width: 1.5),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Hostel Secretary',
                          style: TextStyle(
                              color        : Colors.white,
                              fontSize     : 16,
                              fontWeight   : FontWeight.w800,
                              letterSpacing: -0.2)),
                      SizedBox(height: 3),
                      Text('Currently active role',
                          style: TextStyle(
                              color  : Colors.white70,
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width : 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFF69FF83),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text('Active',
                          style: TextStyle(
                              color     : Colors.white,
                              fontSize  : 11,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Switch Role Card ──────────────────────────────────────────
          GestureDetector(
            onTap: () => _showSwitchSheet(context),
            child: Container(
              width  : double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color       : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border      : Border.all(color: _kBorder, width: 1.2),
                boxShadow   : const [
                  BoxShadow(
                      color     : Color(0x0C1565C0),
                      blurRadius: 12,
                      offset    : Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width : 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color       : _kBlueTint,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: _kBlue, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Switch Role',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize  : 14,
                                color     : _kText)),
                        SizedBox(height: 3),
                        Text('Tap to switch between your roles',
                            style: TextStyle(
                                fontSize: 12, color: _kSubtext)),
                      ],
                    ),
                  ),
                  Container(
                    width : 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color       : _kBlueTint,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(Icons.chevron_right_rounded,
                        color: _kBlue, size: 18),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // ── Services Label ────────────────────────────────────────────
          Row(children: [
            Container(
              width : 36,
              height: 36,
              decoration: BoxDecoration(
                  color       : _kBlueTint,
                  borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.grid_view_rounded,
                  color: _kBlue, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Services',
                style: TextStyle(
                    fontSize     : 16,
                    fontWeight   : FontWeight.w800,
                    color        : _kText,
                    letterSpacing: -0.2)),
          ]),

          const SizedBox(height: 16),

          // ── Services Grid ─────────────────────────────────────────────
          GridView.count(
            shrinkWrap      : true,
            physics         : const NeverScrollableScrollPhysics(),
            crossAxisCount  : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing : 16,
            childAspectRatio: 1.05,
            children: [
              ServiceTile(
                icon : Icons.report_problem_rounded,
                title: 'Complaints',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const HostelSecComplaintsPage()),
                ),
              ),
              ServiceTile(
                icon : Icons.calendar_month_rounded,
                title: 'Attendance',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AttendanceViewPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Role switch bottom sheet ──────────────────────────────────────────────
  void _showSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context            : context,
      backgroundColor    : Colors.transparent,
      isScrollControlled : true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft : Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width : 40,
              height: 4,
              decoration: BoxDecoration(
                color       : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Switch Role',
                  style: TextStyle(
                      fontSize     : 18,
                      fontWeight   : FontWeight.w800,
                      color        : _kText,
                      letterSpacing: -0.3)),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Select the role you want to switch to',
                  style: TextStyle(fontSize: 13, color: _kSubtext)),
            ),
            const SizedBox(height: 20),

            // Hostel Secretary (active)
            _RoleTile(
              icon     : Icons.admin_panel_settings_rounded,
              iconColor: _kBlue,
              iconBg   : _kBlueTint,
              title    : 'Hostel Secretary',
              subtitle : 'Manage complaints & attendance',
              isActive : true,
              onTap    : () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            // Student
            _RoleTile(
              icon     : Icons.person_rounded,
              iconColor: _kSubtext,
              iconBg   : const Color(0xFFF3F4F6),
              title    : 'Student',
              subtitle : 'Access your student dashboard',
              isActive : false,
              onTap    : () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ── Role Tile ─────────────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final IconData     icon;
  final Color        iconColor;
  final Color        iconBg;
  final String       title;
  final String       subtitle;
  final bool         isActive;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kBlueTint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? _kBlue : _kBorder,
            width: isActive ? 1.8 : 1.2,
          ),
        ),
        child: Row(children: [
          Container(
            width : 46,
            height: 46,
            decoration: BoxDecoration(
              color       : isActive ? _kBlue : iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon,
                color: isActive ? Colors.white : iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                        color     : isActive ? _kBlue : _kText)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: _kSubtext)),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color       : _kBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Active',
                  style: TextStyle(
                      color     : Colors.white,
                      fontSize  : 11,
                      fontWeight: FontWeight.w700)),
            )
          else
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: _kSubtext, size: 16),
            ),
        ]),
      ),
    );
  }
}