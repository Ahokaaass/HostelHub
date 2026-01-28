import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceService {
  static final _db = FirebaseFirestore.instance;

  static String monthId() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}";
  }

  static Future<bool> isLocked() async {
    final doc = await _db.collection('attendance').doc(monthId()).get();
    return doc.exists && doc['locked'] == true;
  }

  static Future<void> saveAttendance(
    String studentId,
    String name,
    int room,
    String status,
    bool messCut,
  ) async {
    final mId = monthId();
    final dateKey = DateTime.now().toIso8601String().split('T')[0];

    final ref = _db
        .collection('attendance')
        .doc(mId)
        .collection('records')
        .doc(studentId);

    await _db.collection('attendance').doc(mId).set({
      "locked": false,
    }, SetOptions(merge: true));

    await ref.set({
      "name": name,
      "room": room,
    }, SetOptions(merge: true));

    await ref.collection('days').doc(dateKey).set({
      "status": status,
      "messCut": messCut,
    });

    final snap = await ref.collection('days').get();
    final present =
        snap.docs.where((d) => d['status'] == 'present').length;

    await ref.set({
      "present": present,
      "total": snap.size,
    }, SetOptions(merge: true));
  }

  static Future<void> finalSubmit() async {
    await _db.collection('attendance').doc(monthId()).update({
      "locked": true,
    });
  }
}
