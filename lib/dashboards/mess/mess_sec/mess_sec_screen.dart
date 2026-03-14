import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'otp_store.dart';
import 'others_tab_screen.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class MessSecScreen extends StatefulWidget {
  const MessSecScreen({super.key});

  @override
  State<MessSecScreen> createState() => _MessSecScreenState();
}

class _MessSecScreenState extends State<MessSecScreen> {

  // ── Ordered / Final lists ─────────────────────────────────────────────────
  final List<Map<String, String>> _ordered   = [];
  final List<Map<String, String>> _finalList = [];

  final _itemC  = TextEditingController();
  final _qtyC   = TextEditingController();
  final _brandC = TextEditingController();

  // ── OTP ───────────────────────────────────────────────────────────────────
  final _studentNumC = TextEditingController();
  String? _generatedOtp;

  // ── Loading ───────────────────────────────────────────────────────────────
  bool _sendingOrder = false;

  // ── Add item ──────────────────────────────────────────────────────────────
  void _addItem() {
    if (_itemC.text.trim().isEmpty) return;
    setState(() {
      _ordered.add({
        'item' : _itemC.text.trim(),
        'qty'  : _qtyC.text.trim(),
        'brand': _brandC.text.trim(),
      });
      _itemC.clear();
      _qtyC.clear();
      _brandC.clear();
    });
  }

  // ── Move ordered → final ──────────────────────────────────────────────────
  void _moveToFinal() {
    if (_ordered.isEmpty) return;
    setState(() {
      _finalList.addAll(_ordered);
      _ordered.clear();
    });
    _showSnack('All items moved to Final List');
  }

  // ── Send final list to Firestore ──────────────────────────────────────────
  Future<void> _sendToFirestore() async {
    if (_finalList.isEmpty) return;
    setState(() => _sendingOrder = true);

    try {
      await FirebaseFirestore.instance
          .collection('purchase_orders')
          .add({
        'items'    : _finalList,
        'status'   : 'SENT_TO_PM',
        'createdAt': FieldValue.serverTimestamp(),
      });
      setState(() => _finalList.clear());
      _showSnack('Final list sent to Purchase Manager');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }

    setState(() => _sendingOrder = false);
  }

  // ── Generate OTP ──────────────────────────────────────────────────────────
  void _generateOtp() {
    if (_studentNumC.text.trim().isEmpty) return;
    final otp = (100000 + Random().nextInt(900000)).toString();
    OtpStore.otp      = otp;
    OtpStore.approved = true;
    OtpStore.phone    = _studentNumC.text.trim();
    setState(() => _generatedOtp = otp);
  }

  // ── Verify delivery ───────────────────────────────────────────────────────
  Future<void> _verifyDelivery(DocumentReference ref) async {
    await ref.update({'status': 'VERIFIED'});
    _showSnack('Delivery verified and forwarded!');
  }

  // ── Switch Role bottom sheet ──────────────────────────────────────────────
  void _showSwitchSheet(BuildContext context) {
    showModalBottomSheet(
      context            : context,
      backgroundColor    : Colors.transparent,
      isScrollControlled : true,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft : Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding:
            const EdgeInsets.fromLTRB(24, 12, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width : 40,
              height: 4,
              decoration: BoxDecoration(
                color       : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Switch Role',
                  style: TextStyle(
                      fontSize     : 18,
                      fontWeight   : FontWeight.w800,
                      color        : _kText,
                      letterSpacing: -0.3)),
            ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Select the role you want to switch to',
                  style: TextStyle(
                      fontSize: 13, color: _kSubtext)),
            ),
            const SizedBox(height: 20),

            // ── Mess Secretary (active) ───────────────────────────
            _RoleTile(
              icon     : Icons.restaurant_menu_rounded,
              iconColor: _kBlue,
              iconBg   : _kBlueTint,
              title    : 'Mess Secretary',
              subtitle : 'Manage orders, deliveries & OTP',
              isActive : true,
              onTap    : () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),

            // ── Student ───────────────────────────────────────────
            _RoleTile(
              icon     : Icons.person_rounded,
              iconColor: _kSubtext,
              iconBg   : const Color(0xFFF3F4F6),
              title    : 'Student',
              subtitle : 'Access your student dashboard',
              isActive : false,
              onTap    : () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // go back to student dashboard
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Snackbar ──────────────────────────────────────────────────────────────
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isError
              ? Icons.error_outline_rounded
              : Icons.check_circle_outline_rounded,
          color: Colors.white,
          size : 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontWeight: FontWeight.w500))),
      ]),
      backgroundColor:
          isError ? Colors.red.shade600 : Colors.green.shade600,
      behavior: SnackBarBehavior.floating,
      shape   : RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [

          // ── Header ────────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
                colors: [_kBlue, _kBlueLight],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color     : Color(0x351565C0),
                  blurRadius: 18,
                  offset    : Offset(0, 6),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.3)),
                        ),
                        child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size : 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text('Mess Secretary',
                              style: TextStyle(
                                  color        : Colors.white,
                                  fontSize     : 20,
                                  fontWeight   : FontWeight.w800,
                                  letterSpacing: -0.3)),
                          SizedBox(height: 2),
                          Text(
                              'Manage orders, deliveries & OTP',
                              style: TextStyle(
                                  color  : Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                    // Others button
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                const OthersTabScreen()),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius:
                              BorderRadius.circular(11),
                          border: Border.all(
                              color: Colors.white
                                  .withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.more_horiz,
                                color: Colors.white,
                                size : 18),
                            SizedBox(width: 5),
                            Text('Others',
                                style: TextStyle(
                                    color     : Colors.white,
                                    fontSize  : 12,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Active Role Banner ────────────────────────────────
                  Container(
                    width  : double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin : Alignment.topLeft,
                        end   : Alignment.bottomRight,
                        colors: [_kBlue, _kBlueLight],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color     : Color(0x301565C0),
                          blurRadius: 14,
                          offset    : Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width : 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.35),
                                width: 1.5),
                          ),
                          child: const Icon(
                              Icons.restaurant_menu_rounded,
                              color: Colors.white,
                              size : 28),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text('Mess Secretary',
                                  style: TextStyle(
                                      color        : Colors.white,
                                      fontSize     : 16,
                                      fontWeight   : FontWeight.w800,
                                      letterSpacing: -0.2)),
                              SizedBox(height: 3),
                              Text('Currently active role',
                                  style: TextStyle(
                                      color  : Colors.white70,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.2),
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white
                                    .withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width : 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF69FF83),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Text('Active',
                                  style: TextStyle(
                                      color     : Colors.white,
                                      fontSize  : 11,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Switch Role Card ──────────────────────────────────
                  GestureDetector(
                    onTap: () => _showSwitchSheet(context),
                    child: Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                            color: _kBorder, width: 1.2),
                        boxShadow: const [
                          BoxShadow(
                              color     : Color(0x0C1565C0),
                              blurRadius: 12,
                              offset    : Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width : 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius:
                                  BorderRadius.circular(13),
                            ),
                            child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: _kBlue,
                                size : 22),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text('Switch Role',
                                    style: TextStyle(
                                        fontWeight:
                                            FontWeight.w700,
                                        fontSize: 14,
                                        color   : _kText)),
                                SizedBox(height: 3),
                                Text(
                                    'Tap to switch between your roles',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color   : _kSubtext)),
                              ],
                            ),
                          ),
                          Container(
                            width : 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius:
                                  BorderRadius.circular(9),
                            ),
                            child: const Icon(
                                Icons.chevron_right_rounded,
                                color: _kBlue,
                                size : 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ── ORDERED LIST ──────────────────────────────────────
                  _sectionHeader(
                      Icons.shopping_cart_rounded,
                      'Ordered List'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Item'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _itemC,
                          hint      : 'e.g. Rice',
                          icon      : Icons.fastfood_rounded,
                        ),
                        const SizedBox(height: 10),
                        _fieldLabel('Quantity'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _qtyC,
                          hint      : 'e.g. 50 kg',
                          icon      : Icons.straighten_rounded,
                        ),
                        const SizedBox(height: 10),
                        _fieldLabel('Brand'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _brandC,
                          hint      : 'e.g. India Gate',
                          icon      : Icons
                              .branding_watermark_rounded,
                        ),
                        const SizedBox(height: 14),
                        _blueBtn(
                          icon : Icons.add_rounded,
                          label: 'Add to Current List',
                          onTap: _addItem,
                        ),
                        if (_ordered.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(
                              height: 1, color: _kBorder),
                          const SizedBox(height: 10),
                          ..._ordered
                              .asMap()
                              .entries
                              .map((e) => _itemRow(
                                    e.value,
                                    e.key,
                                    _ordered,
                                  )),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── FINAL LIST ────────────────────────────────────────
                  _sectionHeader(
                      Icons.playlist_add_check_rounded,
                      'Final List'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _blueBtn(
                                icon : Icons.move_down_rounded,
                                label: 'Move All to Final',
                                onTap: _moveToFinal,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _sendingOrder
                                  ? const Center(
                                      child:
                                          CircularProgressIndicator(
                                              color: _kBlue))
                                  : _blueBtn(
                                      icon : Icons.send_rounded,
                                      label: 'Send to PM',
                                      onTap: _sendToFirestore,
                                    ),
                            ),
                          ],
                        ),
                        if (_finalList.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          const Divider(
                              height: 1, color: _kBorder),
                          const SizedBox(height: 10),
                          ..._finalList
                              .asMap()
                              .entries
                              .map((e) => _itemRow(
                                    e.value,
                                    e.key,
                                    _finalList,
                                  )),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 14),
                            child: Row(
                              children: [
                                Icon(
                                    Icons
                                        .info_outline_rounded,
                                    color:
                                        Colors.grey.shade400,
                                    size: 14),
                                const SizedBox(width: 8),
                                const Text(
                                    'No items in final list yet',
                                    style: TextStyle(
                                        fontSize: 12,
                                        color   : _kSubtext)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── RECEIVED LIST ─────────────────────────────────────
                  _sectionHeader(
                      Icons.inventory_2_rounded,
                      'Received List'),
                  const SizedBox(height: 12),
                  _buildReceivedList(),

                  const SizedBox(height: 24),

                  // ── STUDENT OTP ───────────────────────────────────────
                  _sectionHeader(
                      Icons.lock_rounded,
                      'Student OTP Generation'),
                  const SizedBox(height: 12),
                  _card(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Student Number'),
                        const SizedBox(height: 6),
                        _textField(
                          controller  : _studentNumC,
                          hint        : 'Enter student number',
                          icon        : Icons.badge_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _blueBtn(
                          icon : Icons.vpn_key_rounded,
                          label: 'Generate OTP',
                          onTap: _generateOtp,
                        ),
                        if (_generatedOtp != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: _kBlueTint,
                              borderRadius:
                                  BorderRadius.circular(14),
                              border: Border.all(
                                  color: _kBorder),
                            ),
                            child: Column(
                              children: [
                                const Text('Generated OTP',
                                    style: TextStyle(
                                        fontSize  : 12,
                                        color     : _kSubtext,
                                        fontWeight:
                                            FontWeight.w500)),
                                const SizedBox(height: 8),
                                Text(
                                  _generatedOtp!,
                                  style: const TextStyle(
                                    fontSize     : 34,
                                    fontWeight   : FontWeight.w800,
                                    color        : _kBlue,
                                    letterSpacing: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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

  // ── Received list stream ──────────────────────────────────────────────────
  Widget _buildReceivedList() => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('daily_deliveries')
            .orderBy('submittedAt', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                    color: _kBlue),
              ),
            );
          }

          if (snapshot.data!.docs.isEmpty) {
            return _card(
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.grey.shade400, size: 16),
                  const SizedBox(width: 10),
                  const Text('No items received yet',
                      style: TextStyle(
                          fontSize: 12, color: _kSubtext)),
                ],
              ),
            );
          }

          final doc        = snapshot.data!.docs.first;
          final data       = doc.data() as Map<String, dynamic>;
          final items      = List<Map<String, dynamic>>.from(
              data['receivedItems'] ?? []);
          final status     = data['status'] as String? ?? '';
          final isVerified = status == 'VERIFIED';

          return _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? Colors.green.shade50
                            : _kBlueTint,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isVerified
                            ? Icons.verified_rounded
                            : Icons.local_shipping_rounded,
                        color: isVerified
                            ? Colors.green.shade600
                            : _kBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isVerified
                          ? 'Verified'
                          : 'Pending Verification',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize  : 13,
                          color     : isVerified
                              ? Colors.green.shade600
                              : _kText),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: _kBorder),
                const SizedBox(height: 10),
                const Row(children: [
                  Expanded(
                      child: Text('Item',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 11,
                              color     : _kSubtext))),
                  SizedBox(width: 16),
                  Text('Qty',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 11,
                          color     : _kSubtext)),
                  SizedBox(width: 20),
                  Text('Brand',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 11,
                          color     : _kSubtext)),
                ]),
                const SizedBox(height: 6),
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                            child: Text(
                                item['item']?.toString() ?? '',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color   : _kText))),
                        const SizedBox(width: 16),
                        Text(item['qty']?.toString() ?? '',
                            style: const TextStyle(
                                fontSize: 12, color: _kText)),
                        const SizedBox(width: 20),
                        Text(
                            item['brand']?.toString() ?? '',
                            style: const TextStyle(
                                fontSize: 12,
                                color   : _kText)),
                      ],
                    ),
                  ),
                ),
                if (!isVerified) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _verifyDelivery(doc.reference),
                      icon : const Icon(
                          Icons.verified_rounded,
                          size: 18),
                      label: const Text('Verify & Forward',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.green.shade600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );

  // ── Item row ──────────────────────────────────────────────────────────────
  Widget _itemRow(
    Map<String, String> item,
    int index,
    List<Map<String, String>> list,
  ) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.fastfood_rounded,
                  color: _kBlue, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['item'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize  : 13,
                          color     : _kText)),
                  Text(
                      '${item['qty']}  •  ${item['brand']}',
                      style: const TextStyle(
                          fontSize: 11, color: _kSubtext)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () =>
                  setState(() => list.removeAt(index)),
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                      color: Colors.red.shade200),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 14),
              ),
            ),
          ],
        ),
      );

  // ── Shared helpers ────────────────────────────────────────────────────────
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
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _kBlue, size: 18),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize     : 16,
                  fontWeight   : FontWeight.w800,
                  color        : _kText,
                  letterSpacing: -0.2)),
        ],
      );

  Widget _fieldLabel(String label) => Text(label,
      style: const TextStyle(
          fontSize  : 13,
          fontWeight: FontWeight.w600,
          color     : _kText));

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller  : controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14, color: _kText),
        decoration: InputDecoration(
          hintText  : hint,
          hintStyle : const TextStyle(
              color: _kSubtext, fontSize: 13),
          prefixIcon: Icon(icon, color: _kBlue, size: 18),
          filled    : true,
          fillColor : _kBg,
          contentPadding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: _kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(
                  color: _kBlue, width: 1.5)),
        ),
      );

  Widget _blueBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon : Icon(icon, size: 18),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            foregroundColor: Colors.white,
            elevation      : 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE TILE — reusable for the switch sheet
// ─────────────────────────────────────────────────────────────────────────────
class _RoleTile extends StatelessWidget {
  final IconData     icon;
  final Color        iconColor;
  final Color        iconBg;
  final String       title;
  final String       subtitle;
  final bool         isActive;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? _kBlueTint : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? _kBlue : _kBorder,
            width: isActive ? 1.8 : 1.2,
          ),
        ),
        child: Row(children: [
          Container(
            width : 46,
            height: 46,
            decoration: BoxDecoration(
              color       : isActive ? _kBlue : iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon,
                color: isActive ? Colors.white : iconColor,
                size : 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize  : 14,
                        color: isActive ? _kBlue : _kText)),
                const SizedBox(height: 3),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: _kSubtext)),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color       : _kBlue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text('Active',
                  style: TextStyle(
                      color     : Colors.white,
                      fontSize  : 11,
                      fontWeight: FontWeight.w700)),
            )
          else
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: _kSubtext, size: 16),
            ),
        ]),
      ),
    );
  }
}