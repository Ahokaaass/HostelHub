import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyModel {
  final String id;
  final String title;
  final String message;
  final String severity;
  final String status;

  final String? receivedBy;
  final String? handledBy;

  final Timestamp createdAt;
  final String createdBy;

  EmergencyModel({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.createdBy,
    this.receivedBy,
    this.handledBy,
  });

  factory EmergencyModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    return EmergencyModel(
      id: doc.id,
      title: d['title'],
      message: d['message'],
      severity: d['severity'],
      status: d['status'],
      createdAt: d['createdAt'],
      createdBy: d['createdBy'],
      receivedBy: d['receivedBy'],
      handledBy: d['handledBy'],
    );
  }
}
