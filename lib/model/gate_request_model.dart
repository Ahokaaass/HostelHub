// ============================================================
// FILE: lib/model/gate_request_model.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GateStatus {
  static const String pending = 'pending';
  static const String matronForward = 'matronForward';
  static const String matronDecline = 'matronDecline';
  static const String rtForward = 'rtForward';
  static const String rtDecline = 'rtDecline';
  static const String wardenAccept = 'wardenAccept';
  static const String wardenReject = 'wardenReject';
  static const String securityDone = 'securityDone';
}

class GateRequest {
  final String id;
  final String type;
  final String name;
  final String room;
  final String phone;
  final String date;
  final String time;
  final String reason;
  final String studentId;
  final Timestamp? createdAt;

  String status;
  String? matronDeclineReason;
  String? rtDeclineReason;
  String? wardenRejectReason;

  GateRequest({
    required this.id,
    required this.type,
    required this.name,
    required this.room,
    required this.phone,
    required this.date,
    required this.time,
    required this.reason,
    required this.studentId,
    this.createdAt,
    this.status = GateStatus.pending,
    this.matronDeclineReason,
    this.rtDeclineReason,
    this.wardenRejectReason,
  });

  factory GateRequest.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GateRequest(
      id: doc.id,
      type: d['type'] ?? '',
      name: d['name'] ?? '',
      room: d['room'] ?? '',
      phone: d['phone'] ?? '',
      date: d['date'] ?? '',
      time: d['time'] ?? '',
      reason: d['reason'] ?? '',
      studentId: d['studentId'] ?? '',
      createdAt: d['createdAt'] is Timestamp ? d['createdAt'] as Timestamp : null,
      status: d['status'] ?? GateStatus.pending,
      matronDeclineReason: d['matronDeclineReason'],
      rtDeclineReason: d['rtDeclineReason'],
      wardenRejectReason: d['wardenRejectReason'],
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type,
    'name': name,
    'room': room,
    'phone': phone,
    'date': date,
    'time': time,
    'reason': reason,
    'studentId': studentId,
    'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    'status': status,
    'matronDeclineReason': matronDeclineReason,
    'rtDeclineReason': rtDeclineReason,
    'wardenRejectReason': wardenRejectReason,
  };

  String get statusLabel {
    switch (status) {
      case GateStatus.pending:
        return "Pending – Waiting for Matron";
      case GateStatus.matronForward:
        return "Forwarded to RT";
      case GateStatus.matronDecline:
        return "Declined by Matron";
      case GateStatus.rtForward:
        return "Forwarded to Warden";
      case GateStatus.rtDecline:
        return "Declined by RT";
      case GateStatus.wardenAccept:
        return "Approved by Warden ✓";
      case GateStatus.wardenReject:
        return "Rejected by Warden";
      case GateStatus.securityDone:
        return "Approved by Warden ✓";
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case GateStatus.pending:
        return const Color(0xFFFFA000);
      case GateStatus.matronForward:
      case GateStatus.rtForward:
        return const Color(0xFF1976D2);
      case GateStatus.matronDecline:
      case GateStatus.rtDecline:
      case GateStatus.wardenReject:
        return const Color(0xFFD32F2F);
      case GateStatus.wardenAccept:
      case GateStatus.securityDone:
        return const Color(0xFF388E3C);
      default:
        return Colors.grey;
    }
  }

  LogType get logType {
    switch (type) {
      case "Early Entry":
        return LogType.earlyEntry;
      case "Early Going":
        return LogType.earlyExit;
      case "Late Going":
        return LogType.lateExit;
      default:
        return LogType.lateEntry;
    }
  }
}

// ── Firestore Service — NO notifications anywhere ─────────────
class GateRequestService {
  static final _col = FirebaseFirestore.instance.collection('gate_requests');

  // Submit — no notification
  static Future<void> submit(GateRequest r) => _col.add(r.toMap());

  // Stream single document live
  static Stream<GateRequest?> streamSingle(String id) {
    return _col
        .doc(id)
        .snapshots()
        .map((doc) => doc.exists ? GateRequest.fromDoc(doc) : null);
  }

  static Stream<List<GateRequest>> streamForStudent(String studentId) {
    return _col
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Stream<List<GateRequest>> streamForMatron() {
    return _col
        .where('status', isEqualTo: GateStatus.pending)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Stream<List<GateRequest>> streamForRt() {
    return _col
        .where('status', isEqualTo: GateStatus.matronForward)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Stream<List<GateRequest>> streamForWarden() {
    return _col
        .where('status', isEqualTo: GateStatus.rtForward)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Stream<List<GateRequest>> streamForSecurity() {
    return _col
        .where('status', isEqualTo: GateStatus.wardenAccept)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Stream<List<GateRequest>> streamSecurityDone() {
    return _col
        .where('status', isEqualTo: GateStatus.securityDone)
        .snapshots()
        .map((s) => s.docs.map(GateRequest.fromDoc).toList());
  }

  static Future<void> updateStatus(
    String id,
    Map<String, dynamic> fields,
  ) async {
    await _col.doc(id).update(fields);
  }
}

enum LogType { earlyEntry, earlyExit, lateEntry, lateExit }