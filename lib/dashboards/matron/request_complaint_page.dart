import 'package:flutter/material.dart';
import 'complaints_section.dart';
import 'gate_requests_page.dart';

const _kBlue     = Color(0xFF1565C0);
const _kBlueTint = Color(0xFFE8F0FE);

class RequestComplaintPage extends StatelessWidget {
  const RequestComplaintPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: Column(
        children: [

          // ── Header ───────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top   : MediaQuery.of(context).padding.top + 16,
              left  : 20,
              right : 20,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                begin : Alignment.topLeft,
                end   : Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft : Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color        : Colors.white.withOpacity(0.2),
                      borderRadius : BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Requests & Complaints',
                      style: TextStyle(
                        color     : Colors.white,
                        fontSize  : 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Manage student submissions',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Select Category Label ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width : 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color        : _kBlueTint,
                    borderRadius : BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grid_view_rounded,
                      color: _kBlue, size: 16),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Select Category',
                  style: TextStyle(
                    fontSize  : 15,
                    fontWeight: FontWeight.w700,
                    color     : Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Tiles ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _NavTile(
                  icon    : Icons.task_alt_rounded,
                  title   : 'View Requests',
                  subtitle: 'Review and manage student requests',
                  onTap   : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GateRequestsPage()),
                  ),
                ),
                const SizedBox(height: 14),
                _NavTile(
                  icon    : Icons.report_problem_rounded,
                  title   : 'View Complaints',
                  subtitle: 'Forward or reject student complaints',
                  onTap   : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ComplaintsSection()),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nav Tile ──────────────────────────────────────────────────────────────────
class _NavTile extends StatelessWidget {
  final IconData     icon;
  final String       title;
  final String       subtitle;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width      : double.infinity,
        padding    : const EdgeInsets.all(18),
        decoration : BoxDecoration(
          color        : Colors.white,
          borderRadius : BorderRadius.circular(18),
          border       : Border.all(
              color: const Color(0xFFBBD0F8), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color     : Color(0x0C1565C0),
              blurRadius: 12,
              offset    : Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width : 48,
              height: 48,
              decoration: BoxDecoration(
                color        : _kBlueTint,
                borderRadius : BorderRadius.circular(14),
              ),
              child: Icon(icon, color: _kBlue, size: 24),
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
                          color     : Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF6B7280))),
                ],
              ),
            ),
            Container(
              width : 32,
              height: 32,
              decoration: BoxDecoration(
                color        : _kBlueTint,
                borderRadius : BorderRadius.circular(9),
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