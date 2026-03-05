import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class NotificationsPage extends StatelessWidget {
  final String userId;

  const NotificationsPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color     : Color(0x351565C0),
                  blurRadius: 18,
                  offset    : Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notifications',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Announcements & alerts',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder(
              stream: NotificationService.allStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: _kBlue));
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.notifications_off_rounded,
                              color: _kBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No notifications yet',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        const Text('You\'re all caught up!',
                            style: TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final doc  = docs[i];
                    final data = doc.data() as Map<String, dynamic>;

                    final bool isEmergency = data['type'] == 'emergency';
                    final List readBy      = data['readBy'] ?? [];
                    final bool isUnread    = !readBy.contains(userId);

                    // Mark as read on tap for normal notifications
                    Future<void> markRead() async {
                      if (isUnread) {
                        await NotificationService.markRead(
                          notificationId: doc.id,
                          userId        : userId,
                        );
                      }
                    }

                    if (isEmergency) {
                      return _EmergencyBannerCard(
                        createdAt: data['createdAt']?.toDate(),
                        isUnread : isUnread,
                        onTap    : markRead,
                      );
                    }

                    return _NotificationCard(
                      message  : data['message'] ?? '',
                      createdAt: data['createdAt']?.toDate(),
                      isUnread : isUnread,
                      onTap    : markRead,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Normal notification card ──────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final String    message;
  final DateTime? createdAt;
  final bool      isUnread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.message,
    required this.createdAt,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUnread ? _kBlue.withOpacity(0.5) : _kBorder,
            width: isUnread ? 1.5 : 1.2,
          ),
          boxShadow: const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 12,
                offset    : Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width : 44,
              height: 44,
              decoration: BoxDecoration(
                color: isUnread ? _kBlueTint : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                Icons.campaign_rounded,
                color: isUnread ? _kBlue : _kSubtext,
                size : 22,
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Announcement',
                          style: TextStyle(
                              fontSize  : 12,
                              fontWeight: FontWeight.w600,
                              color     : isUnread ? _kBlue : _kSubtext),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width : 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _kBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                        fontSize  : 14,
                        fontWeight: isUnread
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color     : _kText),
                  ),
                  const SizedBox(height: 6),
                  if (createdAt != null)
                    Text(
                      DateFormat("d MMM yyyy • h:mm a").format(createdAt!),
                      style: const TextStyle(
                          fontSize: 11, color: _kSubtext),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Emergency masked banner card ──────────────────────────────────────────────
class _EmergencyBannerCard extends StatelessWidget {
  final DateTime? createdAt;
  final bool      isUnread;
  final VoidCallback onTap;

  const _EmergencyBannerCard({
    required this.createdAt,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border      : Border.all(
              color: Colors.red.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
                color     : Colors.red.withOpacity(0.08),
                blurRadius: 12,
                offset    : const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            // Red top accent
            Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: const BorderRadius.only(
                  topLeft : Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),  // reduced from 16
              child: Row(
                children: [
                  Container(
                    width : 36,   // reduced from 44
                    height: 36,   // reduced from 44
                    decoration: BoxDecoration(
                      color       : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.warning_rounded,
                        color: Colors.red.shade600, size: 18),  // reduced from 22
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Emergency Alert',
                                style: TextStyle(
                                    fontSize  : 11,   // reduced from 12
                                    fontWeight: FontWeight.w700,
                                    color     : Colors.red.shade600)),
                            const Spacer(),
                            if (isUnread)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color       : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.red.shade200),
                                ),
                                child: Text('NEW',
                                    style: TextStyle(
                                        fontSize  : 9,    // reduced from 10
                                        fontWeight: FontWeight.w800,
                                        color     : Colors.red.shade700)),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'New emergency reported in the hostel.',   // shortened text
                          style: TextStyle(
                              fontSize  : 12,   // reduced from 14
                              fontWeight: FontWeight.w600,
                              color     : _kText),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Check Emergency Alerts for details.',     // shortened text
                          style: TextStyle(
                              fontSize: 11,   // reduced from 12
                              color   : Colors.red.shade400),
                        ),
                        const SizedBox(height: 4),
                        if (createdAt != null)
                          Text(
                            DateFormat("d MMM yyyy • h:mm a")
                                .format(createdAt!),
                            style: const TextStyle(
                                fontSize: 11, color: _kSubtext),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}