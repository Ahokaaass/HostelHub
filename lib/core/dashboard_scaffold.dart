import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/notification_service.dart';
import '../dashboards/notifications_page.dart';
import 'session.dart';

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

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // ================= HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
            decoration: const BoxDecoration(
              color: Color(0xFF3A6B52),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(26),
                bottomRight: Radius.circular(26),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ================= APP NAME =================
                      Row(
                        children: const [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.apartment,
                              size: 18,
                              color: Color(0xFF3A6B52),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "HostelHub",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      // ================= NOTIFICATION + PROFILE =================
                      Row(
                        children: [
                          Stack(
                            children: [
                              /// 🔔 BELL ICON (ALWAYS VISIBLE)
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                ),
                                onPressed: userId == null
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NotificationsPage(
                                              userId: userId,
                                            ),
                                          ),
                                        );
                                      },
                              ),

                              /// 🔴 UNREAD INDICATOR (PER USER – FIXED)
                              if (userId != null)
                                StreamBuilder<List<QueryDocumentSnapshot>>(
                                 stream: NotificationService.unreadForUser(userId),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return const SizedBox();
                                    }

                                    final unreadDocs = snapshot.data!;

                                    final bool hasEmergency =
                                        unreadDocs.any((doc) {
                                      final data = doc.data()
                                          as Map<String, dynamic>;
                                      return data['type'] == 'emergency';
                                    });

                                    return Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: hasEmergency
                                            ? const Icon(
                                                Icons.warning,
                                                size: 10,
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

                          /// 👤 PROFILE ICON
                          GestureDetector(
                            onTap: onProfileTap,
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF3A6B52),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    dashboardName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= BODY =================
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: body,
            ),
          ),
        ],
      ),
    );
  }
}
