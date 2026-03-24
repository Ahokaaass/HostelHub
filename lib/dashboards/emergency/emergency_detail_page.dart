import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/session.dart';
import '../../services/notification_service.dart';
import 'emergency_model.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class EmergencyDetailPage extends StatelessWidget {
  final EmergencyModel emergency;

  const EmergencyDetailPage({
    super.key,
    required this.emergency,
  });

  String get role => Session.role ?? 'unknown';

  // ── Mark received ─────────────────────────────────────────────────────────
  Future<void> _markReceived(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergency.id)
        .update({
      "status"    : "received",
      "receivedBy": role,
    });

    // ✅ Removed: NotificationService.send() — no notification on received

    Navigator.pop(context);
  }

  // ── Mark handled ──────────────────────────────────────────────────────────
  Future<void> _markHandled(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection('emergencies')
        .doc(emergency.id)
        .update({
      "status"   : "handled",
      "handledBy": role,
    });

    // ✅ Removed: NotificationService.send() — no notification on handled

    Navigator.pop(context);
  }

  // ── Confirm dialog ────────────────────────────────────────────────────────
  Future<bool?> _confirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required Color  confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize  : 17,
                color     : _kText)),
        content: Text(message,
            style: const TextStyle(color: _kSubtext, fontSize: 14)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: OutlinedButton.styleFrom(
              side : const BorderSide(color: _kBorder),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: const Text('Cancel',
                style: TextStyle(color: _kSubtext)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSubmitted = emergency.status == 'submitted';
    final bool isReceived  = emergency.status == 'received';
    final bool isHandled   = emergency.status == 'handled';

    // Resolve status style
    final Color  statusColor;
    final Color  statusTint;
    final IconData statusIcon;
    final String statusLabel;

    if (isHandled) {
      statusColor = Colors.green.shade600;
      statusTint  = Colors.green.shade50;
      statusIcon  = Icons.check_circle_rounded;
      statusLabel = 'RESOLVED';
    } else if (isReceived) {
      statusColor = Colors.orange.shade700;
      statusTint  = Colors.orange.shade50;
      statusIcon  = Icons.access_time_rounded;
      statusLabel = 'RECEIVED';
    } else {
      statusColor = Colors.red.shade600;
      statusTint  = Colors.red.shade50;
      statusIcon  = Icons.warning_rounded;
      statusLabel = 'ACTIVE';
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: isHandled
                    ? [Colors.green.shade700, Colors.green.shade500]
                    : isReceived
                        ? [Colors.orange.shade700, Colors.orange.shade500]
                        : [Colors.red.shade700,  Colors.red.shade500],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: (isHandled
                              ? Colors.green.shade700
                              : isReceived
                                  ? Colors.orange.shade700
                                  : Colors.red.shade700)
                          .withOpacity(0.3),
                  blurRadius: 18,
                  offset    : const Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width : 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.3)),
                            ),
                            child: const Icon(Icons.arrow_back_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text('Emergency Details',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Status pill
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(statusLabel,
                                  style: const TextStyle(
                                      color     : Colors.white,
                                      fontSize  : 12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.bar_chart_rounded,
                                  color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text('Severity: ${emergency.severity}',
                                  style: const TextStyle(
                                      color    : Colors.white,
                                      fontSize : 12,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ──────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Title card ────────────────────────────────────────
                  _card(
                    child: Row(
                      children: [
                        Container(
                          width : 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color       : statusTint,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(statusIcon,
                              color: statusColor, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(emergency.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize  : 16,
                                      color     : _kText)),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: statusTint,
                                  borderRadius:
                                      BorderRadius.circular(6),
                                  border: Border.all(
                                      color: statusColor
                                          .withOpacity(0.35)),
                                ),
                                child: Text(statusLabel,
                                    style: TextStyle(
                                        fontSize  : 11,
                                        fontWeight: FontWeight.w800,
                                        color     : statusColor,
                                        letterSpacing: 0.3)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Message card ──────────────────────────────────────
                  _sectionHeader(Icons.message_rounded, 'Message'),
                  const SizedBox(height: 12),
                  _card(
                    child: Text(
                      emergency.message,
                      style: const TextStyle(
                          fontSize: 14,
                          color   : _kText,
                          height  : 1.6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Tracking card ─────────────────────────────────────
                  _sectionHeader(
                      Icons.track_changes_rounded, 'Tracking'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      children: [
                        _trackRow(
                          icon : Icons.flag_rounded,
                          label: 'Status',
                          value: emergency.status.toUpperCase(),
                          valueColor: statusColor,
                        ),
                        if (emergency.receivedBy != null) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _kBorder),
                          const SizedBox(height: 14),
                          _trackRow(
                            icon : Icons.person_rounded,
                            label: 'Received by',
                            value: emergency.receivedBy!,
                          ),
                        ],
                        if (emergency.handledBy != null) ...[
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: _kBorder),
                          const SizedBox(height: 14),
                          _trackRow(
                            icon : Icons.verified_rounded,
                            label: 'Handled by',
                            value: emergency.handledBy!,
                            valueColor: Colors.green.shade600,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Action buttons ────────────────────────────────────

                  // SUBMITTED → RECEIVED
                  if (isSubmitted)
                    _actionButton(
                      context,
                      icon        : Icons.check_rounded,
                      label       : 'Mark as Received',
                      color       : Colors.orange.shade700,
                      dialogTitle : 'Confirm Action',
                      dialogMsg   :
                          'Mark this emergency as received by $role?',
                      confirmLabel: 'Mark Received',
                      onConfirm   : () => _markReceived(context),
                    ),

                  // RECEIVED → HANDLED
                  if (isReceived)
                    _actionButton(
                      context,
                      icon        : Icons.verified_rounded,
                      label       : 'Mark as Handled',
                      color       : Colors.green.shade600,
                      dialogTitle : 'Confirm Resolution',
                      dialogMsg   :
                          'Confirm that this emergency has been fully handled by $role?',
                      confirmLabel: 'Mark Handled',
                      onConfirm   : () => _markHandled(context),
                    ),

                  // HANDLED
                  if (isHandled)
                    Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color       : Colors.green.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.green.shade600, size: 20),
                          const SizedBox(width: 10),
                          Text('Emergency Resolved',
                              style: TextStyle(
                                  color     : Colors.green.shade700,
                                  fontSize  : 15,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _kBorder, width: 1.2),
          boxShadow: const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 12,
                offset    : Offset(0, 4)),
          ],
        ),
        child: child,
      );

  Widget _sectionHeader(IconData icon, String title) => Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
                color: _kBlueTint,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _kBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize  : 16,
                  fontWeight: FontWeight.w800,
                  color     : _kText,
                  letterSpacing: -0.2)),
        ],
      );

  Widget _trackRow({
    required IconData icon,
    required String   label,
    required String   value,
    Color?            valueColor,
  }) =>
      Row(
        children: [
          Container(
            width : 32,
            height: 32,
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: _kBlue, size: 16),
          ),
          const SizedBox(width: 12),
          Text('$label:',
              style: const TextStyle(
                  fontSize: 13, color: _kSubtext)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                  fontSize  : 13,
                  fontWeight: FontWeight.w700,
                  color     : valueColor ?? _kText),
            ),
          ),
        ],
      );

  Widget _actionButton(
    BuildContext context, {
    required IconData    icon,
    required String      label,
    required Color       color,
    required String      dialogTitle,
    required String      dialogMsg,
    required String      confirmLabel,
    required VoidCallback onConfirm,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () async {
            final confirmed = await _confirmDialog(
              context,
              title       : dialogTitle,
              message     : dialogMsg,
              confirmLabel: confirmLabel,
              confirmColor: color,
            );
            if (confirmed == true) onConfirm();
          },
          icon : Icon(icon, size: 18),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 15)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}