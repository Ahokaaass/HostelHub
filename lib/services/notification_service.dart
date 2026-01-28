import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  static final _col =
      FirebaseFirestore.instance.collection('notifications');

  /// ================= SEND NOTIFICATION =================
  static Future<void> send({
    required String message,
    required String type, // normal | emergency
  }) async {
    await _col.add({
      'message': message,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'readBy': {}, // 👈 per-user read tracking
    });
  }

  /// ================= UNREAD STREAM (PER USER) =================
  static Stream<QuerySnapshot> unreadStream(String userId) {
    return _col
        .where('readBy.$userId', isNull: true)
        .snapshots();
  }

  /// ================= ALL NOTIFICATIONS (LATEST FIRST) =================
  static Stream<QuerySnapshot> allStream() {
    return _col.orderBy('createdAt', descending: true).snapshots();
  }

  /// ================= MARK ALL AS READ (ONLY FOR USER) =================
  static Future<void> markAllRead(String userId) async {
    final snap = await _col
        .where('readBy.$userId', isNull: true)
        .get();

    for (final d in snap.docs) {
      await d.reference.set({
        'readBy': {userId: true}
      }, SetOptions(merge: true));
    }
  }
}
