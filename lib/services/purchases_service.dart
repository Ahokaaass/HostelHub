import 'package:cloud_firestore/cloud_firestore.dart';

class PurchasesService {
  final FirebaseFirestore _db;

  PurchasesService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  Future<void> addPurchase({
    required String itemName,
    required num quantity,
    required num price,
    required DateTime date,
    required String addedBy,
  }) async {
    final total = quantity * price;
    final doc = <String, dynamic>{
      'itemName': itemName,
      'quantity': quantity,
      'price': price,
      'total': total,
      'date': Timestamp.fromDate(date),
      'addedBy': addedBy,
    };

    await _db.collection('purchases').add(doc);
  }

  Query<Map<String, dynamic>> purchasesQuery({
    DateTime? start,
    DateTime? end,
    int? limit,
  }) {
    Query<Map<String, dynamic>> q = _db
        .collection('purchases')
        .orderBy('date', descending: true);

    if (start != null) {
      q = q.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start));
    }
    if (end != null) {
      q = q.where('date', isLessThanOrEqualTo: Timestamp.fromDate(end));
    }
    if (limit != null) {
      q = q.limit(limit);
    }

    return q;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> streamPurchases({
    DateTime? start,
    DateTime? end,
    int? limit,
  }) {
    return purchasesQuery(start: start, end: end, limit: limit).snapshots();
  }
}
