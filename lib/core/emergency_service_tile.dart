import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const _kBlue     = Color(0xFF1565C0);
const _kBlueTint = Color(0xFFE8F0FE);

/// Same size and structure as ServiceTile.
/// When unread: red border + red icon/label.
/// On tap: marks all as read, then navigates.
class EmergencyServiceTile extends StatelessWidget {
  final String       userId;
  final VoidCallback onTap;

  const EmergencyServiceTile({
    super.key,
    required this.userId,
    required this.onTap,
  });

  Future<void> _markAllRead(List<QueryDocumentSnapshot> docs) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in docs) {
      final data   = doc.data() as Map<String, dynamic>;
      final readBy = List<String>.from(data['readBy'] ?? []);
      if (!readBy.contains(userId)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([userId]),
        });
      }
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('emergencies')
          .snapshots(),
      builder: (context, snapshot) {
        final docs   = snapshot.data?.docs ?? [];
        int   unread = 0;

        for (final doc in docs) {
          final data   = doc.data() as Map<String, dynamic>;
          final readBy = List<String>.from(data['readBy'] ?? []);
          if (!readBy.contains(userId)) unread++;
        }

        final bool hasUnread = unread > 0;

        // ── Single container, no Stack, no Positioned ─────────────────
        // Identical structure to ServiceTile to guarantee same size
        return GestureDetector(
          onTap: () async {
            if (hasUnread) await _markAllRead(docs);
            onTap();
          },
          child: AnimatedContainer(
            duration  : const Duration(milliseconds: 250),
            curve     : Curves.easeInOut,
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(20),
              border      : Border.all(
                color: hasUnread
                    ? Colors.red.shade400
                    : const Color(0xFFBBD0F8),
                width: hasUnread ? 2.0 : 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color     : hasUnread
                      ? Colors.red.withOpacity(0.12)
                      : const Color(0x0F1565C0),
                  blurRadius: 10,
                  offset    : const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon bubble — white background, same as ServiceTile
                Container(
                  width     : 52,
                  height    : 52,
                  decoration: BoxDecoration(
                    color       : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: hasUnread ? Colors.red.shade500 : _kBlue,
                    size : 26,
                  ),
                ),
                const SizedBox(height: 10),

                // Label
                Text(
                  'Emergency Alerts',
                  textAlign: TextAlign.center,
                  style    : TextStyle(
                    fontSize  : 13,
                    fontWeight: FontWeight.w600,
                    color     : hasUnread
                        ? Colors.red.shade600
                        : _kBlue,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}