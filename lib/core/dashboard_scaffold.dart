import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../dashboards/notifications_page.dart';
import 'session.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Shared theme constants — import these in any screen for consistency
// ─────────────────────────────────────────────────────────────────────────────
const kBlue       = Color(0xFF1565C0);
const kBlueLight  = Color(0xFF1E88E5);
const kBlueTint   = Color(0xFFE8F0FE);
const kBlueBorder = Color(0xFFBBD0F8);
const kBgColor    = Color(0xFFF5F8FF);

class DashboardScaffold extends StatelessWidget {
  final String dashboardName;
  final String userName;
  final Widget body;
  final VoidCallback? onProfileTap;

  const DashboardScaffold({
    super.key,
    required this.dashboardName,
    required this.userName,
    required this.body,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final String? userId = Session.userId;
    final String hostel  = Session.hostel ?? '';

    return Scaffold(
      backgroundColor: kBgColor,
      body: Column(
        children: [
          // ════════════════════════ HEADER ════════════════════════════════
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kBlue, kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color     : Color(0x351565C0),
                  blurRadius: 20,
                  offset    : Offset(0, 8),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar: brand  ←→  actions ──────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Brand
                        Row(
                          children: [
                            Container(
                              width : 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [
                                  BoxShadow(
                                    color     : Color(0x201565C0),
                                    blurRadius: 8,
                                    offset    : Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.apartment_rounded,
                                  size: 22, color: kBlue),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'HostelHub',
                                  style: TextStyle(
                                    color     : Colors.white,
                                    fontSize  : 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (hostel.isNotEmpty)
                                  Text(
                                    hostel,
                                    style: TextStyle(
                                      color     : Colors.white.withOpacity(0.72),
                                      fontSize  : 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        // Actions
                        Row(
                          children: [
                            // ── Bell ───────────────────────────────────────
                            Stack(
                              children: [
                                _iconBtn(
                                  icon : Icons.notifications_outlined,
                                  solid: false,
                                  onTap: userId == null
                                      ? null
                                      : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  NotificationsPage(
                                                      userId: userId),
                                            ),
                                          ),
                                ),
                                if (userId != null)
                                  StreamBuilder<
                                      List<QueryDocumentSnapshot>>(
                                    stream: NotificationService
                                        .unreadForUser(userId),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData ||
                                          snapshot.data!.isEmpty) {
                                        return const SizedBox();
                                      }
                                      final hasEmergency =
                                          snapshot.data!.any((doc) {
                                        final d = doc.data()
                                            as Map<String, dynamic>;
                                        return d['type'] == 'emergency';
                                      });
                                      return Positioned(
                                        right: 4,
                                        top  : 4,
                                        child: Container(
                                          width : 14,
                                          height: 14,
                                          decoration: const BoxDecoration(
                                            color: Colors.redAccent,
                                            shape: BoxShape.circle,
                                          ),
                                          child: hasEmergency
                                              ? const Icon(
                                                  Icons.warning_rounded,
                                                  size : 9,
                                                  color: Colors.white,
                                                )
                                              : null,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(width: 10),

                            // ── Profile ────────────────────────────────────
                            _iconBtn(
                              icon : Icons.person_outline_rounded,
                              solid: true,
                              onTap: onProfileTap,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ── Dashboard name ──────────────────────────────────
                    Text(
                      dashboardName,
                      style: const TextStyle(
                        color     : Colors.white,
                        fontSize  : 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // ── User badge ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_rounded,
                              size: 13, color: Colors.white70),
                          const SizedBox(width: 5),
                          Text(
                            userName,
                            style: const TextStyle(
                              color     : Colors.white,
                              fontSize  : 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ════════════════════════ BODY ═══════════════════════════════════
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: body,
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: header icon button ────────────────────────────────────────────
  static Widget _iconBtn({
    required IconData icon,
    required bool solid,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width : 40,
        height: 40,
        decoration: BoxDecoration(
          color: solid
              ? Colors.white
              : Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: solid
              ? null
              : Border.all(
                  color: Colors.white.withOpacity(0.3), width: 1),
          boxShadow: solid
              ? const [
                  BoxShadow(
                    color     : Color(0x201565C0),
                    blurRadius: 8,
                    offset    : Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Icon(icon,
            size : 22,
            color: solid ? kBlue : Colors.white),
      ),
    );
  }
}