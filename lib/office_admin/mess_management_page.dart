import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Theme ─────────────────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class MessManagementPage extends StatelessWidget {
  const MessManagementPage({super.key});

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
                              color:
                                  Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(
                            Icons.arrow_back_rounded,
                            color: Colors.white,
                            size : 20),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mess Management',
                            style: TextStyle(
                                color        : Colors.white,
                                fontSize     : 20,
                                fontWeight   : FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('View, verify & manage mess operations',
                            style: TextStyle(
                                color  : Colors.white70,
                                fontSize: 12)),
                      ],
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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── 1. Ordered List ──────────────────────────────────
                  _sectionHeader(
                      Icons.shopping_cart_rounded,
                      'Ordered List'),
                  const SizedBox(height: 12),
                  _OrderedListSection(),

                  const SizedBox(height: 24),

                  // ── 2. Received List ─────────────────────────────────
                  _sectionHeader(
                      Icons.inventory_2_rounded,
                      'Received List'),
                  const SizedBox(height: 12),
                  _ReceivedListSection(),

                  const SizedBox(height: 24),

                  // ── 3. Bill Calculation ──────────────────────────────
                  _sectionHeader(
                      Icons.calculate_rounded,
                      'Mess Bill Calculation'),
                  const SizedBox(height: 12),
                  _BillCalculationSection(),

                  const SizedBox(height: 24),

                  // ── 4. Mess Bill Verification ────────────────────────
                  _sectionHeader(
                      Icons.receipt_long_rounded,
                      'Mess Bill Verification'),
                  const SizedBox(height: 12),
                  _MessBillVerificationSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Shared header widget ──────────────────────────────────────────────────
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
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. ORDERED LIST
// ─────────────────────────────────────────────────────────────────────────────
class _OrderedListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return _loadingCard();
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyCard(
            icon   : Icons.shopping_cart_rounded,
            message: 'No orders have been placed yet',
          );
        }

        return Column(
          children: docs.map((doc) {
            final data   = doc.data() as Map<String, dynamic>;
            final items  = List<Map<String, dynamic>>.from(
                data['items'] ?? []);
            final status = data['status'] as String? ?? '';
            final ts     = data['createdAt'] as Timestamp?;
            final date   = ts != null
                ? _formatDate(ts.toDate())
                : 'Unknown date';

            return _card(
              margin: const EdgeInsets.only(bottom: 12),
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color       : _kBlueTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                            Icons.receipt_long_rounded,
                            color: _kBlue,
                            size : 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Order · $date',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 13,
                                    color     : _kText)),
                            Text('${items.length} items',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color   : _kSubtext)),
                          ],
                        ),
                      ),
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _kBorder),
                  const SizedBox(height: 10),

                  // Column headings
                  _tableHeading(),
                  const SizedBox(height: 4),

                  // Items
                  ...items.map((item) => _tableRow(
                        item['item']?.toString() ?? '',
                        item['qty']?.toString() ?? '',
                        item['brand']?.toString() ?? '',
                      )),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. RECEIVED LIST
// ─────────────────────────────────────────────────────────────────────────────
class _ReceivedListSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('daily_deliveries')
          .orderBy('submittedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loadingCard();

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyCard(
            icon   : Icons.inventory_2_rounded,
            message: 'No deliveries recorded yet',
          );
        }

        return Column(
          children: docs.map((doc) {
            final data       = doc.data() as Map<String, dynamic>;
            final items      = List<Map<String, dynamic>>.from(
                data['receivedItems'] ?? []);
            final status     = data['status'] as String? ?? '';
            final isVerified = status == 'VERIFIED';

            return _card(
              margin: const EdgeInsets.only(bottom: 12),
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green.shade50
                              : _kBlueTint,
                          borderRadius:
                              BorderRadius.circular(10),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery · ${items.length} items',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize  : 13,
                                  color     : _kText),
                            ),
                            Text(
                              isVerified
                                  ? 'Verified by Mess Secretary'
                                  : 'Pending verification',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: isVerified
                                      ? Colors.green.shade600
                                      : _kSubtext),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _kBorder),
                  const SizedBox(height: 10),
                  _tableHeading(),
                  const SizedBox(height: 4),
                  ...items.map((item) => _tableRow(
                        item['item']?.toString() ?? '',
                        item['qty']?.toString() ?? '',
                        item['brand']?.toString() ?? '',
                      )),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. BILL CALCULATION
// ─────────────────────────────────────────────────────────────────────────────
class _BillCalculationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Reads veg/non-veg counts from the others_tab_screen data
    // stored under 'mess_bill' collection, or falls back to static rates
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mess_bill')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        // ── Fallback static calculation if no Firestore data ──────────
        int vegCount    = 0;
        int nonVegCount = 0;
        int vegRate     = 90;
        int nonVegRate  = 110;

        if (snapshot.hasData &&
            snapshot.data!.docs.isNotEmpty) {
          final d = snapshot.data!.docs.first.data()
              as Map<String, dynamic>;
          vegCount    = (d['vegCount']    as num?)?.toInt() ?? 0;
          nonVegCount = (d['nonVegCount'] as num?)?.toInt() ?? 0;
          vegRate     = (d['vegRate']     as num?)?.toInt() ?? 90;
          nonVegRate  = (d['nonVegRate']  as num?)?.toInt() ?? 110;
        }

        final int vegTotal    = vegCount * vegRate;
        final int nonVegTotal = nonVegCount * nonVegRate;
        final int grandTotal  = vegTotal + nonVegTotal;

        return _card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Veg row
              _billCalcRow(
                icon   : Icons.eco_rounded,
                label  : 'Veg Students',
                detail : '$vegCount × ₹$vegRate',
                amount : '₹$vegTotal',
                color  : Colors.green.shade600,
              ),
              const SizedBox(height: 12),

              // Non-veg row
              _billCalcRow(
                icon   : Icons.set_meal_rounded,
                label  : 'Non-Veg Students',
                detail : '$nonVegCount × ₹$nonVegRate',
                amount : '₹$nonVegTotal',
                color  : Colors.orange.shade600,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1, color: _kBorder),
              ),

              // Total
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Grand Total',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize  : 15,
                          color     : _kText)),
                  Text('₹$grandTotal',
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize  : 17,
                          color     : _kBlue)),
                ],
              ),

              const SizedBox(height: 4),
              Text(
                'Based on ₹$vegRate/day veg · ₹$nonVegRate/day non-veg',
                style: const TextStyle(
                    fontSize: 11, color: _kSubtext),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _billCalcRow({
    required IconData icon,
    required String label,
    required String detail,
    required String amount,
    required Color  color,
  }) =>
      Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
              color       : color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize  : 13,
                        color     : _kText)),
                Text(detail,
                    style: const TextStyle(
                        fontSize: 11, color: _kSubtext)),
              ],
            ),
          ),
          Text(amount,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize  : 14,
                  color     : color)),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. MESS BILL VERIFICATION
// ─────────────────────────────────────────────────────────────────────────────
class _MessBillVerificationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('purchase_orders')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _loadingCard();

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return _emptyCard(
            icon   : Icons.receipt_long_rounded,
            message: 'No bills to verify yet',
          );
        }

        return Column(
          children: docs.map((doc) {
            final data       = doc.data() as Map<String, dynamic>;
            final items      = List<Map<String, dynamic>>.from(
                data['items'] ?? []);
            final status     = data['status'] as String? ?? '';
            final ts         = data['createdAt'] as Timestamp?;
            final date       = ts != null
                ? _formatDate(ts.toDate())
                : 'Unknown date';
            final isVerified = status == 'VERIFIED';
            final isSent     = status == 'SENT_TO_PM';

            return _card(
              margin: const EdgeInsets.only(bottom: 14),
              child : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bill header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? Colors.green.shade50
                              : _kBlueTint,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isVerified
                              ? Icons.verified_rounded
                              : Icons.receipt_long_rounded,
                          color: isVerified
                              ? Colors.green.shade600
                              : _kBlue,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text('Bill · $date',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 13,
                                    color     : _kText)),
                            Text('${items.length} items',
                                style: const TextStyle(
                                    fontSize: 11,
                                    color   : _kSubtext)),
                          ],
                        ),
                      ),
                      _statusChip(status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: _kBorder),
                  const SizedBox(height: 10),

                  // Items preview
                  _tableHeading(),
                  const SizedBox(height: 4),
                  ...items.map((item) => _tableRow(
                        item['item']?.toString() ?? '',
                        item['qty']?.toString() ?? '',
                        item['brand']?.toString() ?? '',
                      )),

                  // Action buttons — only shown when not yet verified
                  if (!isVerified) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Verify
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await doc.reference
                                  .update({'status': 'VERIFIED'});
                              if (context.mounted) {
                                _showSnack(context,
                                    'Bill verified successfully',
                                    isSuccess: true);
                              }
                            },
                            icon : const Icon(
                                Icons.check_circle_rounded,
                                size: 16),
                            label: const Text('Verify',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.green.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Resend
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await doc.reference.update(
                                  {'status': 'SENT_TO_PM'});
                              if (context.mounted) {
                                _showSnack(context,
                                    'Bill resent to Purchase Manager');
                              }
                            },
                            icon : const Icon(
                                Icons.send_rounded,
                                size: 16),
                            label: const Text('Resend',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize  : 13)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.orange.shade600,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(
                                      vertical: 11),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                          10)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Already verified badge
                  if (isVerified) ...[
                    const SizedBox(height: 12),
                    Container(
                      width  : double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius:
                            BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: Colors.green.shade600,
                              size : 16),
                          const SizedBox(width: 6),
                          Text('Bill Verified',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize  : 13,
                                  color: Colors.green
                                      .shade600)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _showSnack(BuildContext context, String msg,
      {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          isSuccess
              ? Icons.check_circle_outline_rounded
              : Icons.send_rounded,
          color: Colors.white,
          size : 18,
        ),
        const SizedBox(width: 10),
        Expanded(
            child: Text(msg,
                style: const TextStyle(
                    fontWeight: FontWeight.w500))),
      ]),
      backgroundColor: isSuccess
          ? Colors.green.shade600
          : Colors.orange.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED HELPERS — used by all 4 sections
// ─────────────────────────────────────────────────────────────────────────────

Widget _card({required Widget child, EdgeInsets? margin}) =>
    Container(
      width  : double.infinity,
      margin : margin,
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

Widget _loadingCard() => _card(
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child:
              CircularProgressIndicator(color: _kBlue),
        ),
      ),
    );

Widget _emptyCard(
        {required IconData icon, required String message}) =>
    _card(
      child: Row(
        children: [
          Container(
            width : 36,
            height: 36,
            decoration: BoxDecoration(
              color       : _kBlueTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _kBlue, size: 18),
          ),
          const SizedBox(width: 12),
          Text(message,
              style: const TextStyle(
                  fontSize: 13, color: _kSubtext)),
        ],
      ),
    );

Widget _tableHeading() => const Row(
      children: [
        Expanded(
            child: Text('Item',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
        SizedBox(width: 12),
        SizedBox(
            width: 60,
            child: Text('Qty',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
        SizedBox(width: 12),
        SizedBox(
            width: 80,
            child: Text('Brand',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize  : 11,
                    color     : _kSubtext))),
      ],
    );

Widget _tableRow(String item, String qty, String brand) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
              child: Text(item,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 60,
              child: Text(qty,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
          const SizedBox(width: 12),
          SizedBox(
              width: 80,
              child: Text(brand,
                  style: const TextStyle(
                      fontSize: 12, color: _kText))),
        ],
      ),
    );

Widget _statusChip(String status) {
  Color bg, fg;
  String label;
  switch (status) {
    case 'VERIFIED':
      bg    = Colors.green.shade50;
      fg    = Colors.green.shade700;
      label = 'Verified';
      break;
    case 'SENT_TO_PM':
      bg    = Colors.orange.shade50;
      fg    = Colors.orange.shade700;
      label = 'Sent to PM';
      break;
    default:
      bg    = _kBlueTint;
      fg    = _kBlue;
      label = status.isEmpty ? 'Pending' : status;
  }
  return Container(
    padding: const EdgeInsets.symmetric(
        horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
        color       : bg,
        borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize  : 10,
            fontWeight: FontWeight.w700,
            color     : fg)),
  );
}

String _formatDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/'
    '${dt.month.toString().padLeft(2, '0')}/'
    '${dt.year}';