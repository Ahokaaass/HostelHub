import 'package:flutter/material.dart';
import 'outgoing_list_page.dart';

// ── Theme constants ───────────────────────────────────────────────────────────
const _kBlue      = Color(0xFF1565C0);
const _kBlueLight = Color(0xFF1E88E5);
const _kBlueTint  = Color(0xFFE8F0FE);
const _kBorder    = Color(0xFFBBD0F8);
const _kBg        = Color(0xFFF5F8FF);
const _kText      = Color(0xFF1A1A2E);
const _kSubtext   = Color(0xFF6B7280);

class OutgoingCategoryPage extends StatelessWidget {
  const OutgoingCategoryPage({super.key});

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
                      children: const [
                        Text('Outgoing Records',
                            style: TextStyle(
                                color     : Colors.white,
                                fontSize  : 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3)),
                        SizedBox(height: 2),
                        Text('Choose a category to view',
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

          // ── Categories ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section header
                  Row(
                    children: [
                      Container(
                        width : 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color       : _kBlueTint,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.list_alt_rounded,
                            color: _kBlue, size: 18),
                      ),
                      const SizedBox(width: 10),
                      const Text('Select Category',
                          style: TextStyle(
                              fontSize  : 16,
                              fontWeight: FontWeight.w800,
                              color     : _kText,
                              letterSpacing: -0.2)),
                    ],
                  ),
                  const SizedBox(height: 18),

                  _CategoryCard(
                    icon     : Icons.arrow_outward_rounded,
                    iconColor: _kBlue,
                    iconBg   : _kBlueTint,
                    title    : 'Outgoing',
                    subtitle : 'Regular outgoing records',
                    onTap    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OutgoingListPage(
                              type: 'Outgoing')),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CategoryCard(
                    icon     : Icons.home_outlined,
                    iconColor: Color(0xFF2E7D32),
                    iconBg   : Color(0xFFE8F5E9),
                    title    : 'Home Going',
                    subtitle : 'Students who went home',
                    onTap    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OutgoingListPage(
                              type: 'Home Going')),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _CategoryCard(
                    icon     : Icons.local_hospital_outlined,
                    iconColor: Color(0xFFC62828),
                    iconBg   : Color(0xFFFFEBEE),
                    title    : 'Hospital Going',
                    subtitle : 'Students who went to hospital',
                    onTap    : () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const OutgoingListPage(
                              type: 'Hospital Going')),
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
}

// ── Category card ─────────────────────────────────────────────────────────────
class _CategoryCard extends StatelessWidget {
  final IconData icon;
  final Color    iconColor;
  final Color    iconBg;
  final String   title;
  final String   subtitle;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width  : double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color       : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border      : Border.all(color: _kBorder, width: 1.2),
          boxShadow   : const [
            BoxShadow(
                color     : Color(0x0C1565C0),
                blurRadius: 12,
                offset    : Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width : 50,
              height: 50,
              decoration: BoxDecoration(
                color       : iconBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize  : 15,
                          color     : _kText)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: _kSubtext)),
                ],
              ),
            ),
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color       : _kBlueTint,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: _kBlue, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}