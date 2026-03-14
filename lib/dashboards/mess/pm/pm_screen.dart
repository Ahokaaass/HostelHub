import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../mess_sec/otp_store.dart';

const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class PmScreen extends StatefulWidget {
  const PmScreen({super.key});

  @override
  State<PmScreen> createState() => _PmScreenState();
}

class _PmScreenState extends State<PmScreen> {
  final _commodityC = TextEditingController();
  final _quantityC  = TextEditingController();
  final _brandC     = TextEditingController();

  // Local list before submitting to Firestore
  final List<Map<String, dynamic>> _receivedItems = [];
  bool _submitting = false;

  // ── Access check ──────────────────────────────────────────────────────────
  bool get _hasAccess => OtpStore.approved;

  // ── Add item to local list ────────────────────────────────────────────────
  void _addItem() {
    if (!_hasAccess) {
      _showSnack(
          'Access denied: Mess Secretary approval required',
          isError: true);
      return;
    }

    final commodity = _commodityC.text.trim();
    final qty =
        double.tryParse(_quantityC.text.trim()) ?? 0;
    final brand = _brandC.text.trim();

    if (commodity.isEmpty || qty <= 0) {
      _showSnack(
          'Enter a valid commodity name and quantity',
          isError: true);
      return;
    }

    setState(() {
      _receivedItems.add({
        'item' : commodity,
        'qty'  : qty.toString(),
        'brand': brand.isEmpty ? 'N/A' : brand,
      });
      _commodityC.clear();
      _quantityC.clear();
      _brandC.clear();
    });

    _showSnack('Item added to received list');
  }

  // ── Submit received list to Firestore ─────────────────────────────────────
  Future<void> _submitDelivery() async {
    if (_receivedItems.isEmpty) {
      _showSnack('Add at least one item before submitting',
          isError: true);
      return;
    }

    setState(() => _submitting = true);

    try {
      await FirebaseFirestore.instance
          .collection('daily_deliveries')
          .add({
        'receivedItems': _receivedItems,
        'status'       : 'PENDING',
        'submittedAt'  : FieldValue.serverTimestamp(),
      });

      setState(() => _receivedItems.clear());
      _showSnack(
          'Delivery submitted to Mess Secretary for verification');
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }

    setState(() => _submitting = false);
  }

  // ── Remove item ───────────────────────────────────────────────────────────
  void _removeItem(int index) {
    setState(() => _receivedItems.removeAt(index));
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
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _commodityC.dispose();
    _quantityC.dispose();
    _brandC.dispose();
    super.dispose();
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
                padding: const EdgeInsets.fromLTRB(
                    20, 14, 20, 24),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          Navigator.pop(context),
                      child: Container(
                        width : 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.18),
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
                          Text('Purchase Manager',
                              style: TextStyle(
                                  color        : Colors.white,
                                  fontSize     : 20,
                                  fontWeight   : FontWeight.w800,
                                  letterSpacing: -0.3)),
                          SizedBox(height: 2),
                          Text(
                              'Mark received items & submit delivery',
                              style: TextStyle(
                                  color  : Colors.white70,
                                  fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                  20, 24, 20, 36),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ── Access status banner ───────────────────────
                  Container(
                    width  : double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _hasAccess
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: _hasAccess
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width : 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _hasAccess
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius:
                                BorderRadius.circular(
                                    10),
                          ),
                          child: Icon(
                            _hasAccess
                                ? Icons
                                    .check_circle_rounded
                                : Icons.lock_rounded,
                            color: _hasAccess
                                ? Colors.green.shade600
                                : Colors.red.shade500,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _hasAccess
                                ? 'Access approved by Mess Secretary'
                                : 'Access pending — Mess Secretary approval required',
                            style: TextStyle(
                              fontSize  : 13,
                              fontWeight: FontWeight.w600,
                              color     : _hasAccess
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Add received item section ──────────────────
                  _sectionHeader(
                      Icons.add_shopping_cart_rounded,
                      'Mark Items as Received'),
                  const SizedBox(height: 12),

                  _card(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('Commodity Name'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _commodityC,
                          hint      : 'e.g. Rice',
                          icon      : Icons.fastfood_rounded,
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Quantity'),
                        const SizedBox(height: 6),
                        _textField(
                          controller  : _quantityC,
                          hint        : 'e.g. 50',
                          icon        : Icons.straighten_rounded,
                          keyboardType:
                              TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        _fieldLabel('Brand (optional)'),
                        const SizedBox(height: 6),
                        _textField(
                          controller: _brandC,
                          hint      : 'e.g. India Gate',
                          icon      : Icons
                              .branding_watermark_rounded,
                        ),
                        const SizedBox(height: 16),
                        _blueBtn(
                          icon : Icons.add_rounded,
                          label: 'Add to Received List',
                          onTap: _addItem,
                        ),
                      ],
                    ),
                  ),

                  // ── Received items list ────────────────────────
                  if (_receivedItems.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionHeader(
                        Icons.inventory_2_rounded,
                        'Received List (${_receivedItems.length})'),
                    const SizedBox(height: 12),
                    _card(
                      child: Column(
                        children: [
                          ...List.generate(
                            _receivedItems.length,
                            (index) {
                              final item =
                                  _receivedItems[index];
                              final isLast = index ==
                                  _receivedItems.length -
                                      1;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets
                                        .symmetric(
                                        vertical: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                          width : 34,
                                          height: 34,
                                          decoration:
                                              BoxDecoration(
                                            color: _kBlueTint,
                                            borderRadius:
                                                BorderRadius
                                                    .circular(
                                                        9),
                                          ),
                                          child: const Icon(
                                              Icons
                                                  .fastfood_rounded,
                                              color: _kBlue,
                                              size : 16),
                                        ),
                                        const SizedBox(
                                            width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                            children: [
                                              Text(
                                                item['item'] ??
                                                    '',
                                                style: const TextStyle(
                                                    fontWeight:
                                                        FontWeight
                                                            .w600,
                                                    fontSize:
                                                        13,
                                                    color:
                                                        _kText),
                                              ),
                                              Text(
                                                'Qty: ${item['qty']}  •  Brand: ${item['brand']}',
                                                style: const TextStyle(
                                                    fontSize:
                                                        11,
                                                    color:
                                                        _kSubtext),
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _removeItem(
                                                  index),
                                          child: Container(
                                            padding:
                                                const EdgeInsets
                                                    .all(5),
                                            decoration:
                                                BoxDecoration(
                                              color: Colors
                                                  .red
                                                  .shade50,
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          7),
                                              border: Border.all(
                                                  color: Colors
                                                      .red
                                                      .shade200),
                                            ),
                                            child: Icon(
                                                Icons
                                                    .delete_outline_rounded,
                                                color: Colors
                                                    .red
                                                    .shade400,
                                                size: 14),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isLast)
                                    const Divider(
                                        height: 1,
                                        color : _kBorder),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          // Submit button
                          _submitting
                              ? const Center(
                                  child:
                                      CircularProgressIndicator(
                                          color: _kBlue))
                              : SizedBox(
                                  width: double.infinity,
                                  child:
                                      ElevatedButton.icon(
                                    onPressed:
                                        _submitDelivery,
                                    icon : const Icon(
                                        Icons.send_rounded,
                                        size: 18),
                                    label: const Text(
                                        'Submit Delivery',
                                        style: TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .w700,
                                            fontSize: 14)),
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor:
                                          Colors
                                              .green.shade600,
                                      foregroundColor:
                                          Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets
                                          .symmetric(
                                          vertical: 13),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius
                                                  .circular(
                                                      12)),
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],

                  // ── Past deliveries stream ─────────────────────
                  const SizedBox(height: 24),
                  _sectionHeader(
                      Icons.history_rounded,
                      'Past Deliveries'),
                  const SizedBox(height: 12),
                  _PastDeliveriesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _sectionHeader(IconData icon, String title) =>
      Row(
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
              borderSide  : const BorderSide(
                  color: _kBorder)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(
                  color: _kBorder)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide  : const BorderSide(
                  color: _kBlue, width: 1.5)),
        ),
      );

  Widget _blueBtn({
    required IconData    icon,
    required String      label,
    required VoidCallback onTap,
  }) =>
      SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon : Icon(icon, size: 18),
          label: Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 14)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBlue,
            foregroundColor: Colors.white,
            elevation      : 0,
            padding: const EdgeInsets.symmetric(
                vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAST DELIVERIES STREAM WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _PastDeliveriesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_deliveries')
          .orderBy('submittedAt', descending: true)
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

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return Container(
            width  : double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                  color: _kBorder, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Colors.grey.shade400,
                    size : 16),
                const SizedBox(width: 10),
                const Text('No deliveries submitted yet',
                    style: TextStyle(
                        fontSize: 12,
                        color   : _kSubtext)),
              ],
            ),
          );
        }

        return Column(
          children: docs.map((doc) {
            final data       = doc.data()
                as Map<String, dynamic>;
            final items      =
                List<Map<String, dynamic>>.from(
                    data['receivedItems'] ?? []);
            final status     =
                data['status'] as String? ?? '';
            final isVerified = status == 'VERIFIED';
            final ts =
                data['submittedAt'] as Timestamp?;
            final date = ts != null
                ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                : '—';

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isVerified
                      ? Colors.green.shade200
                      : _kBorder,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                      color     : Color(0x0C1565C0),
                      blurRadius: 8,
                      offset    : Offset(0, 3)),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(6),
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
                              : Icons
                                  .pending_rounded,
                          color: isVerified
                              ? Colors.green.shade600
                              : _kBlue,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Delivery · $date · ${items.length} items',
                          style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 12,
                              color   : _kText),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical  : 3),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green.shade50
                              : Colors.orange.shade50,
                          borderRadius:
                              BorderRadius.circular(
                                  20),
                        ),
                        child: Text(
                          isVerified
                              ? 'Verified'
                              : 'Pending',
                          style: TextStyle(
                            fontSize  : 10,
                            fontWeight: FontWeight.w700,
                            color     : isVerified
                                ? Colors.green.shade700
                                : Colors
                                    .orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (items.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Divider(
                        height: 1, color: _kBorder),
                    const SizedBox(height: 6),
                    ...items.map((item) => Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                  vertical: 2),
                          child: Row(
                            children: [
                              const Icon(
                                  Icons
                                      .fiber_manual_record,
                                  size : 5,
                                  color: _kSubtext),
                              const SizedBox(width: 6),
                              Expanded(
                                  child: Text(
                                item['item']
                                        ?.toString() ??
                                    '',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color   : _kText),
                              )),
                              Text(
                                '${item['qty']}  •  ${item['brand']}',
                                style: const TextStyle(
                                    fontSize: 10,
                                    color   : _kSubtext),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}