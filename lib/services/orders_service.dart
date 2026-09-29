import 'package:cloud_firestore/cloud_firestore.dart';

class OrdersService {
  final FirebaseFirestore _db;

  OrdersService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('purchase_orders');

  Future<void> sendOrderToPurchaseManager({
    required List<Map<String, dynamic>> items,
  }) async {
    final docRef = _orders.doc();
    await docRef.set({
      'items': items,
      'status': 'PENDING_APPROVAL',
      'approvedByMess': false,
      'sentToPM': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await docRef.update({
      'status': 'SENT_TO_PM',
      'approvedByMess': true,
      'sentToPM': true,
      'sentAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPmEligibleOrders({
    int limit = 1,
  }) {
    return _orders
        .where('approvedByMess', isEqualTo: true)
        .where('sentToPM', isEqualTo: true)
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots();
  }
}
