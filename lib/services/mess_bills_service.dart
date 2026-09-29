import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mess_bill_entry.dart';

class MessBillsService {
  final FirebaseFirestore _db;

  MessBillsService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  Stream<List<MessBillEntry>> streamMessBills({int limit = 50}) {
    return _db
        .collection('mess_bills')
        .orderBy('month', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map(MessBillEntry.fromDoc).toList());
  }

  Future<void> finalizeBill(String docId) async {
    await _db.collection('mess_bills').doc(docId).update({
      'status': 'final',
      'finalizedAt': FieldValue.serverTimestamp(),
    });
  }
}
