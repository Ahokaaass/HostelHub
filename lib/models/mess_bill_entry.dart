import 'package:cloud_firestore/cloud_firestore.dart';

class MessBillEntry {
  final String docId;
  final String studentName;
  final String month;
  final num breakfastCount;
  final num lunchCount;
  final num dinnerCount;
  final num messBill;
  final num commonBill;
  final num finalBill;
  final String status;
  final DateTime? finalizedAt;

  const MessBillEntry({
    required this.docId,
    required this.studentName,
    required this.month,
    required this.breakfastCount,
    required this.lunchCount,
    required this.dinnerCount,
    required this.messBill,
    required this.commonBill,
    required this.finalBill,
    required this.status,
    required this.finalizedAt,
  });

  static MessBillEntry fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data();
    final month = (d['month'] ?? '').toString();

    num readNum(String key) {
      final v = d[key];
      if (v is num) return v;
      if (v is String) return num.tryParse(v) ?? 0;
      return 0;
    }

    final finalizedAtTs = d['finalizedAt'] as Timestamp?;
    final finalizedAt = finalizedAtTs?.toDate();

    return MessBillEntry(
      docId: doc.id,
      studentName: (d['studentName'] ?? d['name'] ?? '').toString(),
      month: month,
      breakfastCount: readNum('breakfastCount'),
      lunchCount: readNum('lunchCount'),
      dinnerCount: readNum('dinnerCount'),
      messBill: readNum('messBill'),
      commonBill: readNum('commonBill'),
      finalBill: readNum('finalBill'),
      status: (d['status'] ?? 'draft').toString(),
      finalizedAt: finalizedAt,
    );
  }
}
