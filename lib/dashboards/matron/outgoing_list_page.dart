import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class OutgoingListPage extends StatelessWidget {
  final String type;
  const OutgoingListPage({super.key, required this.type});

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
                        Text(type,
                            style: const TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        const SizedBox(height: 2),
                        const Text('Live records from database',
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










          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('outgoing')
                  .where('type', isEqualTo: type)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator(color: _kBlue));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: const TextStyle(
                            color: Colors.redAccent)),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width : 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(Icons.inbox_rounded,
                              color: _kBlue, size: 32),
                        ),
                        const SizedBox(height: 16),
                        const Text('No records found',
                            style: TextStyle(
                                color     : _kText,
                                fontSize  : 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text('No $type records available',
                            style: const TextStyle(
                                color  : _kSubtext,
                                fontSize: 13)),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(20, 24, 20, 36),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final r =
                        docs[i].data() as Map<String, dynamic>;
                    final hasReturn = r['returnDate'] != null;
                    return _OutgoingCard(data: r, hasReturn: hasReturn);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Outgoing card (view-only, mirrors student design) ─────────────────────────
class _OutgoingCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final bool hasReturn;

  const _OutgoingCard({
    required this.data,
    required this.hasReturn,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border      : Border.all(color: _kBorder, width: 1.2),
          boxShadow   : const [
            BoxShadow(
                color     : Color(0x0F1565C0),
                blurRadius: 10,
                offset    : Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top row ──────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width : 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color       : _kBlueTint,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person_outline_rounded,
                      color: _kBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize  : 15,
                              color     : _kText)),
                      Text(
                        'Room ${data['room'] ?? '-'}  •  ${data['place'] ?? '-'}',
                        style: const TextStyle(
                            fontSize: 12, color: _kSubtext),
                      ),
                    ],
                  ),
                ),
                // Return status badge
                hasReturn
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: const Text('Returned',
                            style: TextStyle(
                                fontSize  : 11,
                                color     : Color(0xFF2E7D32),
                                fontWeight: FontWeight.w700)),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius:
                              BorderRadius.circular(10),
                          border: Border.all(
                              color: Colors.orange.shade200),
                        ),
                        child: Text('Out',
                            style: TextStyle(
                                fontSize  : 11,
                                color     : Colors.orange.shade700,
                                fontWeight: FontWeight.w700)),
                      ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F0F0)),
            const SizedBox(height: 12),

            // ── Departure + Return chips ──────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _infoChip(
                    Icons.login_rounded,
                    'Departed',
                    data['outDate'] ?? '—',
                    data['outTime'] ?? '—',
                    _kBlueTint,
                    _kBlue,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _infoChip(
                    Icons.logout_rounded,
                    'Return',
                    hasReturn ? (data['returnDate'] ?? '—') : '—',
                    hasReturn
                        ? (data['returnTime'] ?? '—')
                        : 'Not yet updated',
                    hasReturn
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF8E1),
                    hasReturn
                        ? const Color(0xFF2E7D32)
                        : const Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _infoChip(
    IconData icon,
    String   heading,
    String   line1,
    String   line2,
    Color    bg,
    Color    color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(heading,
                    style: TextStyle(
                        fontSize  : 10,
                        color     : color.withOpacity(0.8),
                        fontWeight: FontWeight.w500)),
                Text(line1,
                    style: TextStyle(
                        fontSize  : 12,
                        fontWeight: FontWeight.w700,
                        color     : color)),
                Text(line2,
                    style: const TextStyle(
                        fontSize: 11, color: _kSubtext)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}