import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/notification_service.dart';
import '../../core/session.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class SendNotificationPage extends StatefulWidget {
  const SendNotificationPage({super.key});

  @override
  State<SendNotificationPage> createState() => _SendNotificationPageState();
}

class _SendNotificationPageState extends State<SendNotificationPage> {
  final TextEditingController msgCtrl = TextEditingController();
  String type = 'normal';
  bool _sending = false;

  bool get _isEmergency => type == 'emergency';

  Future<void> _send() async {
    if (msgCtrl.text.trim().isEmpty) return;

    // Confirm before sending
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor : Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: Text(
          _isEmergency ? 'Send Emergency Alert?' : 'Send Notice?',
          style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize  : 17,
              color     : _kText),
        ),
        content: Text(
          _isEmergency
              ? 'This will broadcast a HIGH-severity emergency alert to all students immediately.'
              : 'This notice will be sent to all students.',
          style: const TextStyle(color: _kSubtext, fontSize: 14),
        ),
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
              backgroundColor: _isEmergency
                  ? Colors.red.shade600
                  : _kBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
            ),
            child: Text(_isEmergency ? 'Send Alert' : 'Send'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _sending = true);

    if (_isEmergency) {
      await FirebaseFirestore.instance.collection('emergencies').add({
        "title"    : "Emergency Alert",
        "message"  : msgCtrl.text.trim(),
        "severity" : "High",
        "createdBy": Session.role,
        "createdAt": Timestamp.now(),
        "status"   : "submitted",
        "receivedBy": null,
        "handledBy" : null,
      });
    }

    await NotificationService.send(
      message  : msgCtrl.text.trim(),
      type     : type,
      extraData: {"createdBy": Session.role},
    );

    setState(() => _sending = false);

    // Success snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _isEmergency
                    ? 'Emergency alert sent successfully'
                    : 'Notice sent successfully',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: _isEmergency
            ? Colors.red.shade600
            : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 400));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: _isEmergency
                    ? [Colors.red.shade700, Colors.red.shade400]
                    : [_kBlue, _kBlueLight],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color     : (_isEmergency
                          ? Colors.red.shade700
                          : _kBlue)
                      .withOpacity(0.3),
                  blurRadius: 18,
                  offset    : const Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Send Notice',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        Text(
                          _isEmergency
                              ? 'Broadcasting emergency alert'
                              : 'Broadcast a message to all students',
                          style: const TextStyle(
                              color  : Colors.white70,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ─────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Notification Type ──────────────────────────────────
                  _sectionHeader(
                      Icons.tune_rounded, 'Notification Type'),
                  const SizedBox(height: 16),

                  // Type toggle cards
                  Row(
                    children: [
                      Expanded(
                        child: _TypeCard(
                          label    : 'Normal',
                          icon     : Icons.notifications_rounded,
                          selected : type == 'normal',
                          color    : _kBlue,
                          tintColor: _kBlueTint,
                          onTap    : () =>
                              setState(() => type = 'normal'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TypeCard(
                          label    : 'Emergency',
                          icon     : Icons.warning_rounded,
                          selected : type == 'emergency',
                          color    : Colors.red.shade600,
                          tintColor: Colors.red.shade50,
                          onTap    : () =>
                              setState(() => type = 'emergency'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Emergency banner ───────────────────────────────────
                  if (_isEmergency) ...[
                    Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin : const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color : Colors.red.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded,
                              color: Colors.red.shade600, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'This will create a high-severity emergency record and alert all students immediately.',
                              style: TextStyle(
                                  color    : Colors.red.shade700,
                                  fontSize : 12,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // ── Message ────────────────────────────────────────────
                  _sectionHeader(
                      Icons.edit_note_rounded, 'Message'),
                  const SizedBox(height: 16),

                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Notice Content',
                            style: TextStyle(
                                fontSize  : 13,
                                fontWeight: FontWeight.w600,
                                color     : _kText)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: msgCtrl,
                          maxLines  : 6,
                          style: const TextStyle(
                              fontSize: 14, color: _kText),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Type your message here…',
                            hintStyle: const TextStyle(
                                color: _kSubtext, fontSize: 13),
                            filled    : true,
                            fillColor : _kBg,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide  :
                                  const BorderSide(color: _kBorder),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide  :
                                  const BorderSide(color: _kBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide  : BorderSide(
                                color: _isEmergency
                                    ? Colors.red.shade600
                                    : _kBlue,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        if (msgCtrl.text.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${msgCtrl.text.length} characters',
                              style: const TextStyle(
                                  fontSize: 11, color: _kSubtext),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── Send button ────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: _sending
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: _kBlue))
                        : ElevatedButton.icon(
                            onPressed: msgCtrl.text.trim().isEmpty
                                ? null
                                : _send,
                            icon : Icon(
                              _isEmergency
                                  ? Icons.warning_rounded
                                  : Icons.send_rounded,
                              size: 18,
                            ),
                            label: Text(
                              _isEmergency
                                  ? 'Send Emergency Alert'
                                  : 'Send Notice',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize  : 15),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isEmergency
                                  ? Colors.red.shade600
                                  : _kBlue,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  _kBorder,
                              disabledForegroundColor:
                                  Colors.white60,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(14)),
                            ),
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
        padding: const EdgeInsets.all(18),
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
}

// ── Type selector card ────────────────────────────────────────────────────────
class _TypeCard extends StatelessWidget {
  final String     label;
  final IconData   icon;
  final bool       selected;
  final Color      color;
  final Color      tintColor;
  final VoidCallback onTap;

  const _TypeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.tintColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? color : _kBorder,
            width: selected ? 0 : 1.2,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color     : color.withOpacity(0.3),
                    blurRadius: 12,
                    offset    : const Offset(0, 4),
                  )
                ]
              : [
                  const BoxShadow(
                    color     : Color(0x0C1565C0),
                    blurRadius: 8,
                    offset    : Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : color,
              size : 26,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                  color     : selected ? Colors.white : _kText,
                  fontWeight: FontWeight.w700,
                  fontSize  : 13),
            ),
          ],
        ),
      ),
    );
  }
}